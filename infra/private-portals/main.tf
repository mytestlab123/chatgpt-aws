terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }

  backend "s3" {}
}

variable "aws_region" {
  type        = string
  description = "Region for the private S3 origins."
  default     = "ap-southeast-1"
}

variable "allowed_ipv4_cidr" {
  type        = string
  description = "Single IPv4 /32 allowed by the WAF portal. Supply at runtime; do not commit a personal address."
  sensitive   = true

  validation {
    condition     = can(cidrhost(var.allowed_ipv4_cidr, 0)) && endswith(var.allowed_ipv4_cidr, "/32")
    error_message = "allowed_ipv4_cidr must be a valid IPv4 /32 CIDR."
  }
}

variable "basic_auth_sha256" {
  type        = string
  description = "SHA-256 hex digest of the complete HTTP Authorization header. Supply at runtime; never commit the raw password."
  sensitive   = true

  validation {
    condition     = can(regex("^[0-9a-f]{64}$", var.basic_auth_sha256))
    error_message = "basic_auth_sha256 must be a lowercase 64-character SHA-256 hex digest."
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

locals {
  prefix           = "agent-private-portals"
  ip_bucket_name   = "${local.prefix}-ip-${data.aws_caller_identity.current.account_id}"
  auth_bucket_name = "${local.prefix}-auth-${data.aws_caller_identity.current.account_id}"

  common_tags = {
    project      = "agent-private-portals"
    environment  = "lab"
    purpose      = "private-static-portal-learning"
    "managed-by" = "terraform"
  }

  ip_portal_html = <<-HTML
    <!doctype html>
    <html lang="en">
      <head><meta charset="utf-8"><title>Private Portal - IP Allowlist</title></head>
      <body>
        <h1>Private CloudFront Portal</h1>
        <p>Access control: AWS WAF IPv4 allowlist.</p>
        <p id="marker">PRIVATE-PORTAL-IP-ALLOWLIST-PASS</p>
      </body>
    </html>
  HTML

  auth_portal_html = <<-HTML
    <!doctype html>
    <html lang="en">
      <head><meta charset="utf-8"><title>Private Portal - Basic Auth</title></head>
      <body>
        <h1>Private CloudFront Portal</h1>
        <p>Access control: CloudFront Function Basic Auth.</p>
        <p id="marker">PRIVATE-PORTAL-BASIC-AUTH-PASS</p>
      </body>
    </html>
  HTML
}

resource "aws_s3_bucket" "ip_portal" {
  bucket = local.ip_bucket_name
  tags   = local.common_tags
}

resource "aws_s3_bucket" "auth_portal" {
  bucket = local.auth_bucket_name
  tags   = local.common_tags
}

resource "aws_s3_bucket_ownership_controls" "ip_portal" {
  bucket = aws_s3_bucket.ip_portal.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_ownership_controls" "auth_portal" {
  bucket = aws_s3_bucket.auth_portal.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "ip_portal" {
  bucket                  = aws_s3_bucket.ip_portal.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "auth_portal" {
  bucket                  = aws_s3_bucket.auth_portal.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ip_portal" {
  bucket = aws_s3_bucket.ip_portal.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "auth_portal" {
  bucket = aws_s3_bucket.auth_portal.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "ip_index" {
  bucket       = aws_s3_bucket.ip_portal.id
  key          = "index.html"
  content      = local.ip_portal_html
  content_type = "text/html; charset=utf-8"
  etag         = md5(local.ip_portal_html)
}

resource "aws_s3_object" "auth_index" {
  bucket       = aws_s3_bucket.auth_portal.id
  key          = "index.html"
  content      = local.auth_portal_html
  content_type = "text/html; charset=utf-8"
  etag         = md5(local.auth_portal_html)
}

resource "aws_cloudfront_origin_access_control" "portals" {
  name                              = "${local.prefix}-oac"
  description                       = "Private S3 access for the private static portal examples"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_wafv2_ip_set" "allowed_viewer" {
  provider           = aws.us_east_1
  name               = "${local.prefix}-allowed-viewer"
  description        = "Runtime-provided IPv4 /32 allowed to the IP portal"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = [var.allowed_ipv4_cidr]
  tags               = local.common_tags
}

resource "aws_wafv2_web_acl" "ip_portal" {
  provider    = aws.us_east_1
  name        = "${local.prefix}-ip-web-acl"
  description = "Default deny; allow only the configured viewer IPv4 /32"
  scope       = "CLOUDFRONT"

  default_action {
    block {}
  }

  rule {
    name     = "AllowConfiguredViewer"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.allowed_viewer.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "agent-private-portals-allow-viewer"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "agent-private-portals-ip-web-acl"
    sampled_requests_enabled   = true
  }

  tags = local.common_tags
}

resource "aws_cloudfront_function" "basic_auth" {
  name    = "${local.prefix}-basic-auth"
  comment = "Viewer-request Basic Auth verifier for the private portal lab"
  runtime = "cloudfront-js-2.0"
  publish = true

  code = <<-JS
    var crypto = require('crypto');
    var expected = '${var.basic_auth_sha256}';

    function handler(event) {
      var request = event.request;
      var header = request.headers.authorization;

      if (header && header.value) {
        var actual = crypto.createHash('sha256').update(header.value).digest('hex');
        if (actual === expected) {
          return request;
        }
      }

      return {
        statusCode: 401,
        statusDescription: 'Unauthorized',
        headers: {
          'www-authenticate': { value: 'Basic realm="Private portal"' },
          'cache-control': { value: 'no-store' }
        }
      };
    }
  JS
}

resource "aws_cloudfront_distribution" "ip_portal" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Private static portal - AWS WAF IP allowlist"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  web_acl_id          = aws_wafv2_web_acl.ip_portal.arn

  origin {
    domain_name              = aws_s3_bucket.ip_portal.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.portals.id
    origin_id                = "ip-portal-s3"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "ip-portal-s3"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 60
    max_ttl     = 300
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

resource "aws_cloudfront_distribution" "auth_portal" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Private static portal - CloudFront Function Basic Auth"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  origin {
    domain_name              = aws_s3_bucket.auth_portal.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.portals.id
    origin_id                = "auth-portal-s3"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "auth-portal-s3"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.basic_auth.arn
    }

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 60
    max_ttl     = 300
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

data "aws_iam_policy_document" "ip_bucket" {
  statement {
    sid     = "AllowCloudFrontRead"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.ip_portal.arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.ip_portal.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "ip_portal" {
  bucket = aws_s3_bucket.ip_portal.id
  policy = data.aws_iam_policy_document.ip_bucket.json
}

data "aws_iam_policy_document" "auth_bucket" {
  statement {
    sid     = "AllowCloudFrontRead"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.auth_portal.arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.auth_portal.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "auth_portal" {
  bucket = aws_s3_bucket.auth_portal.id
  policy = data.aws_iam_policy_document.auth_bucket.json
}

output "ip_portal_url" {
  value = "https://${aws_cloudfront_distribution.ip_portal.domain_name}"
}

output "basic_auth_portal_url" {
  value = "https://${aws_cloudfront_distribution.auth_portal.domain_name}"
}

output "ip_distribution_id" {
  value = aws_cloudfront_distribution.ip_portal.id
}

output "basic_auth_distribution_id" {
  value = aws_cloudfront_distribution.auth_portal.id
}

output "ip_web_acl_arn" {
  value = aws_wafv2_web_acl.ip_portal.arn
}
