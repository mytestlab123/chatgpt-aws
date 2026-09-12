terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }

  backend "s3" {
    bucket  = "chatgpt-aws-tfstate-063884340510"
    key     = "state/chatgpt-aws/sfn-sqs.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

data "aws_caller_identity" "current" {}

locals {
  region                    = "ap-southeast-1"
  account_id                = data.aws_caller_identity.current.account_id
  queue_name                = "chatgpt-aws-sfn-sqs-smoke"
  state_machine_name        = "chatgpt-aws-sfn-sqs-smoke"
  state_machine_arn         = "arn:aws:states:${local.region}:${local.account_id}:stateMachine:${local.state_machine_name}"
  state_machine_execution   = "arn:aws:states:${local.region}:${local.account_id}:execution:${local.state_machine_name}:*"
  github_oidc_provider_arn  = "arn:aws:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"
  github_org_id             = "58461665"
  github_repository_id      = "1366899390"
}

resource "aws_sqs_queue" "smoke" {
  name                      = local.queue_name
  message_retention_seconds = 600
  visibility_timeout_seconds = 30

  tags = {
    project      = "chatgpt-aws"
    environment  = "lab"
    purpose      = "sfn-sqs-oidc-mcp"
    "managed-by" = "terraform"
  }
}

resource "aws_iam_role" "step_functions" {
  name = "chatgpt-aws-sfn-sqs-smoke"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = local.account_id
        }
        ArnLike = {
          "aws:SourceArn" = local.state_machine_arn
        }
      }
    }]
  })

  tags = {
    project      = "chatgpt-aws"
    environment  = "lab"
    purpose      = "sfn-sqs-execution"
    "managed-by" = "terraform"
  }
}

resource "aws_iam_role_policy" "step_functions" {
  name = "SendOnlyToDedicatedQueue"
  role = aws_iam_role.step_functions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "SendDedicatedQueueMessage"
      Effect   = "Allow"
      Action   = "sqs:SendMessage"
      Resource = aws_sqs_queue.smoke.arn
    }]
  })
}

resource "aws_sfn_state_machine" "smoke" {
  name     = local.state_machine_name
  role_arn = aws_iam_role.step_functions.arn
  type     = "STANDARD"

  definition = jsonencode({
    Comment = "Deterministic OIDC -> Step Functions -> SQS smoke workflow"
    StartAt = "SendQueueMessage"
    States = {
      SendQueueMessage = {
        Type     = "Task"
        Resource = "arn:aws:states:::sqs:sendMessage"
        Parameters = {
          QueueUrl = aws_sqs_queue.smoke.url
          MessageBody = {
            marker = "OIDC-SFN-SQS-PASS"
            source = "step-functions"
          }
        }
        ResultPath = "$.sqs"
        Next       = "Complete"
      }
      Complete = {
        Type = "Pass"
        Result = {
          status = "SUCCEEDED"
        }
        End = true
      }
    }
  })

  tags = {
    project      = "chatgpt-aws"
    environment  = "lab"
    purpose      = "sfn-sqs-oidc-mcp"
    "managed-by" = "terraform"
  }

  depends_on = [aws_iam_role_policy.step_functions]
}

resource "aws_iam_role" "github_execution" {
  name = "github-actions-chatgpt-aws-sfn-lab"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = local.github_oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [
            "repo:mytestlab123/chatgpt-aws:pull_request",
            "repo:mytestlab123/chatgpt-aws:ref:refs/heads/main",
            "repo:mytestlab123@${local.github_org_id}/chatgpt-aws@${local.github_repository_id}:pull_request",
            "repo:mytestlab123@${local.github_org_id}/chatgpt-aws@${local.github_repository_id}:ref:refs/heads/main"
          ]
        }
      }
    }]
  })

  tags = {
    project      = "chatgpt-aws"
    environment  = "lab"
    purpose      = "sfn-sqs-github-execution"
    "managed-by" = "terraform"
  }
}

resource "aws_iam_role_policy" "github_execution" {
  name = "RunOnlyDedicatedStateMachine"
  role = aws_iam_role.github_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "StartAndReadDedicatedStateMachine"
        Effect   = "Allow"
        Action   = ["states:StartExecution", "states:DescribeStateMachine"]
        Resource = local.state_machine_arn
      },
      {
        Sid      = "ReadDedicatedExecutions"
        Effect   = "Allow"
        Action   = ["states:DescribeExecution", "states:GetExecutionHistory"]
        Resource = local.state_machine_execution
      },
      {
        Sid      = "VerifyAndCleanDedicatedQueue"
        Effect   = "Allow"
        Action   = ["sqs:GetQueueAttributes", "sqs:GetQueueUrl", "sqs:ReceiveMessage", "sqs:DeleteMessage"]
        Resource = aws_sqs_queue.smoke.arn
      }
    ]
  })
}

output "queue_url" {
  value = aws_sqs_queue.smoke.url
}

output "queue_arn" {
  value = aws_sqs_queue.smoke.arn
}

output "state_machine_arn" {
  value = aws_sfn_state_machine.smoke.arn
}

output "github_execution_role_arn" {
  value = aws_iam_role.github_execution.arn
}
