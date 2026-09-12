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
    key     = "state/chatgpt-aws/drift-demo.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_ssm_parameter" "drift_demo" {
  name        = "/chatgpt-aws/drift-demo"
  description = "Persistent low-cost resource for ChatGPT AWS IaC drift experiments"
  type        = "String"
  value       = "desired-v1"

  tags = {
    project      = "chatgpt-aws"
    environment  = "lab"
    purpose      = "drift-demo"
    "managed-by" = "terraform"
  }
}

output "parameter_name" {
  value = aws_ssm_parameter.drift_demo.name
}
