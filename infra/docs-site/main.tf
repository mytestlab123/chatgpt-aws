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
    key     = "state/chatgpt-aws/docs-site.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

locals {
  bucket_name = "chatgpt-aws-docs-063884340510"
  origin_id   = "chatgpt-aws-docs-s3"

  common_tags = {
    project      = "chatgpt-aws"
    environment  = "lab"
    purpose      = "material-docs"
    "managed-by" = "terraform"
  }
}

resource "aws_s3_bucket" "docs" {
  bucket = local.bucket_name

  tags = local.common_tags
}

resource "aws_s3_bucket_ownership_controls" "docs" {
  bucket = aws_s3_bucket.docs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "docs" {
  bucket = aws_s3_bucket.docs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "docs" {
  bucket = aws_s3_bucket.docs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_cloudfront_origin_access_control" "docs" {
  name                              = "chatgpt-aws-docs-oac"
  description                       = "Private S3 access for the ChatGPT AWS Material documentation site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "docs" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "ChatGPT AWS Material for MkDocs documentation"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  origin {
    domain_name              = aws_s3_bucket.docs.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.docs.id
    origin_id                = local.origin_id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 300
    max_ttl     = 86400
  }

  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 10
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = local.common_tags
}

data "aws_iam_policy_document" "docs_bucket" {
  statement {
    sid     = "AllowCloudFrontRead"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.docs.arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.docs.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "docs" {
  bucket = aws_s3_bucket.docs.id
  policy = data.aws_iam_policy_document.docs_bucket.json
}

output "bucket_name" {
  value = aws_s3_bucket.docs.bucket
}

output "distribution_id" {
  value = aws_cloudfront_distribution.docs.id
}

output "distribution_domain_name" {
  value = aws_cloudfront_distribution.docs.domain_name
}

output "site_url" {
  value = "https://${aws_cloudfront_distribution.docs.domain_name}"
}
