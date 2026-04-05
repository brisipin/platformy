resource "aws_s3_bucket" "frontend" {
  count  = var.create_frontend_hosting ? 1 : 0
  bucket = "${var.name_prefix}-frontend"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  count  = var.create_frontend_hosting ? 1 : 0
  bucket = aws_s3_bucket.frontend[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "frontend" {
  count = var.create_frontend_hosting ? 1 : 0

  name                              = "${var.name_prefix}-frontend"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

locals {
  # Use try() so this local only depends on aws_eip.app, not aws_instance.app.
  # This breaks the cycle: aws_instance.app -> CloudFront -> local -> aws_instance.app.
  # A lifecycle precondition on the CloudFront resource enforces that associate_elastic_ip
  # must be true whenever create_frontend_hosting is true.
  api_ec2_ip     = try(aws_eip.app[0].public_ip, "")
  api_ec2_domain = local.api_ec2_ip != "" ? "ec2-${replace(local.api_ec2_ip, ".", "-")}.${data.aws_region.current.name}.compute.amazonaws.com" : ""
}

resource "aws_cloudfront_distribution" "frontend" {
  count = var.create_frontend_hosting ? 1 : 0

  lifecycle {
    precondition {
      condition     = var.associate_elastic_ip
      error_message = "create_frontend_hosting = true requires associate_elastic_ip = true for a stable EC2 origin domain."
    }
  }

  enabled             = true
  default_root_object = "index.html"
  comment             = "${var.name_prefix} frontend"
  tags                = var.tags

  # S3 origin — serves the React app
  origin {
    domain_name              = aws_s3_bucket.frontend[0].bucket_regional_domain_name
    origin_id                = "s3-frontend"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend[0].id
  }

  # EC2 origin — serves the FastAPI backend
  origin {
    domain_name = local.api_ec2_domain
    origin_id   = "ec2-api"

    custom_origin_config {
      http_port              = var.app_port
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Default: serve the React SPA from S3
  default_cache_behavior {
    target_origin_id       = "s3-frontend"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  # API paths: forward to EC2 with no caching, all methods, all cookies/headers
  dynamic "ordered_cache_behavior" {
    for_each = [
      "/auth", "/auth/*",
      "/me", "/me/*",
      "/groups", "/groups/*",
      "/teams", "/teams/*",
      "/series", "/series/*",
      "/users", "/users/*",
      "/health",
    ]
    content {
      path_pattern           = ordered_cache_behavior.value
      target_origin_id       = "ec2-api"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods         = ["GET", "HEAD"]
      compress               = false

      cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
      origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac" # AllViewerExceptHostHeader
    }
  }

  # SPA fallback: serve index.html for unknown paths so Vue Router handles routing
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_s3_bucket_policy" "frontend" {
  count  = var.create_frontend_hosting ? 1 : 0
  bucket = aws_s3_bucket.frontend[0].id

  depends_on = [aws_s3_bucket_public_access_block.frontend]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "cloudfront.amazonaws.com" }
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.frontend[0].arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.frontend[0].arn
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "github_frontend_deploy" {
  count = var.create_frontend_hosting && length(var.github_actions_ecr_push_repositories) > 0 ? 1 : 0

  name_prefix = "frontend-deploy-"
  role        = aws_iam_role.github_ecr_push[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.frontend[0].arn,
          "${aws_s3_bucket.frontend[0].arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["cloudfront:CreateInvalidation"]
        Resource = aws_cloudfront_distribution.frontend[0].arn
      }
    ]
  })
}
