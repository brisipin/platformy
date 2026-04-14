# ── Analytics (Parquet output from ETL) ─────────────────────────────────────

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

# ── Database backups (pg_dump → S3) ──────────────────────────────────────────

resource "aws_s3_bucket" "backups" {
  bucket = "${var.name_prefix}-backups"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "backups" {
  bucket = aws_s3_bucket.backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "backups" {
  bucket = aws_s3_bucket.backups.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Expire daily backups after 30 days; weekly (Sunday) backups kept for 1 year.
resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    id     = "expire-daily"
    status = "Enabled"
    filter { prefix = "daily/" }
    expiration { days = 30 }
  }

  rule {
    id     = "expire-weekly"
    status = "Enabled"
    filter { prefix = "weekly/" }
    expiration { days = 365 }
  }
}

# Grant the GitHub Actions role access to: write backups, write analytics, and
# read the Supabase DATABASE_URL secret so it can connect for pg_dump.
resource "aws_iam_role_policy" "github_etl" {
  count = length(var.github_actions_ecr_push_repositories) > 0 ? 1 : 0

  name_prefix = "etl-s3-"
  role        = aws_iam_role.github_ecr_push[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket", "s3:GetBucketLocation"]
        Resource = [
          aws_s3_bucket.analytics.arn,
          "${aws_s3_bucket.analytics.arn}/*",
          aws_s3_bucket.backups.arn,
          "${aws_s3_bucket.backups.arn}/*",
        ]
      },
      {
        # pg_dump needs the Supabase connection string at backup time.
        Effect = "Allow"
        Action = ["secretsmanager:GetSecretValue"]
        Resource = [
          "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.name_prefix}/database-url*",
        ]
      },
    ]
  })
}
