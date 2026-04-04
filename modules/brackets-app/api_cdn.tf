locals {
  api_origin_domain = length(aws_eip.app) > 0 ? aws_eip.app[0].public_ip : aws_instance.app.public_ip
}

resource "aws_cloudfront_distribution" "api" {
  enabled = true
  comment = "${var.name_prefix} api"
  tags    = var.tags

  origin {
    domain_name = local.api_origin_domain
    origin_id   = "ec2-api"

    custom_origin_config {
      http_port              = var.app_port
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "ec2-api"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    compress               = false

    # Disable caching — forward everything to the origin
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
    origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac" # AllViewerExceptHostHeader
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
