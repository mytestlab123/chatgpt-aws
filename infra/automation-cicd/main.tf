terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4, < 3.0"
    }
  }

  backend "s3" {
    bucket  = "chatgpt-aws-tfstate-063884340510"
    key     = "state/chatgpt-aws/automation-cicd.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  project       = "chatgpt-aws"
  bucket_name   = "chatgpt-aws-automation-${data.aws_caller_identity.current.account_id}"
  ecr_name      = "chatgpt-aws-cicd-lab"
  table_name    = "chatgpt-aws-automation-events"
  function_name = "chatgpt-aws-automation-recorder"
  lambda_role   = "chatgpt-aws-automation-lambda"
  event_rule    = "chatgpt-aws-automation-events"

  tags = {
    project       = local.project
    environment   = "lab"
    purpose       = "automation-cicd"
    "managed-by" = "terraform"
    issue         = "9"
  }
}

resource "aws_ecr_repository" "cicd" {
  name                 = local.ecr_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = local.tags
}

resource "aws_s3_bucket" "automation" {
  bucket        = local.bucket_name
  force_destroy = true
  tags          = local.tags
}

resource "aws_s3_bucket_public_access_block" "automation" {
  bucket = aws_s3_bucket.automation.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "automation" {
  bucket = aws_s3_bucket.automation.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "mcp_guard_fixture" {
  bucket       = aws_s3_bucket.automation.id
  key          = "mcp-guard/protected.txt"
  content      = "Retained fixture for aws:ViaAWSMCPService delete-deny verification.\n"
  content_type = "text/plain"

  tags = {
    purpose = "mcp-governance-fixture"
  }
}

resource "aws_dynamodb_table" "events" {
  name         = local.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  tags = local.tags
}

resource "aws_iam_role" "lambda" {
  name = local.lambda_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "lambda" {
  name = "automation-recorder-runtime"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "WriteAutomationEvidence"
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem"]
        Resource = aws_dynamodb_table.events.arn
      },
      {
        Sid    = "WriteLambdaLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.automation.arn}:*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "automation" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = 1
  tags              = local.tags
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "automation" {
  function_name = local.function_name
  role          = aws_iam_role.lambda.arn
  handler       = "lambda.handler"
  runtime       = "python3.12"
  timeout       = 10
  memory_size   = 128

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.events.name
    }
  }

  tags = local.tags

  depends_on = [
    aws_iam_role_policy.lambda,
    aws_cloudwatch_log_group.automation
  ]
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.automation.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.automation.arn
  source_account = data.aws_caller_identity.current.account_id
}

resource "aws_s3_bucket_notification" "automation" {
  bucket = aws_s3_bucket.automation.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.automation.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "events/"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

resource "aws_cloudwatch_event_rule" "automation" {
  name        = local.event_rule
  description = "Custom event trigger for ChatGPT AWS automation lab"

  event_pattern = jsonencode({
    source      = ["chatgpt.aws.lab"]
    detail-type = ["automation-test"]
  })

  tags = local.tags
}

resource "aws_cloudwatch_event_target" "automation" {
  rule      = aws_cloudwatch_event_rule.automation.name
  target_id = "automation-recorder"
  arn       = aws_lambda_function.automation.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.automation.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.automation.arn
}

output "automation_bucket" {
  value = aws_s3_bucket.automation.id
}

output "ecr_repository" {
  value = aws_ecr_repository.cicd.name
}

output "event_table" {
  value = aws_dynamodb_table.events.name
}

output "lambda_function" {
  value = aws_lambda_function.automation.function_name
}

output "event_rule" {
  value = aws_cloudwatch_event_rule.automation.name
}

output "mcp_guard_object" {
  value = "s3://${aws_s3_bucket.automation.id}/${aws_s3_object.mcp_guard_fixture.key}"
}
