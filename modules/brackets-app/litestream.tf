resource "aws_s3_bucket" "litestream" {
  bucket = "${var.name_prefix}-litestream"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "litestream" {
  bucket = aws_s3_bucket.litestream.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "litestream" {
  bucket = aws_s3_bucket.litestream.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ── Analytics (Parquet output) ───────────────────────────────────────────────

resource "aws_s3_bucket" "analytics" {
  bucket = "${var.name_prefix}-analytics"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "analytics" {
  bucket = aws_s3_bucket.analytics.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Grant GitHub Actions role: read from litestream, write to analytics
resource "aws_iam_role_policy" "github_etl" {
  count = length(var.github_actions_ecr_push_repositories) > 0 ? 1 : 0

  name_prefix = "etl-s3-"
  role        = aws_iam_role.github_ecr_push[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:ListBucket", "s3:GetBucketLocation"]
        Resource = [
          aws_s3_bucket.litestream.arn,
          "${aws_s3_bucket.litestream.arn}/*",
        ]
      },
      {
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket", "s3:GetBucketLocation"]
        Resource = [
          aws_s3_bucket.analytics.arn,
          "${aws_s3_bucket.analytics.arn}/*",
        ]
      }
    ]
  })
}
