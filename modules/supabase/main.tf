# Generate a strong DB password managed entirely by Terraform/OpenTofu.
resource "random_password" "db" {
  length  = 32
  special = false # Supabase restricts some special characters in the DB password
}

resource "supabase_project" "main" {
  organization_id   = var.organization_id
  name              = var.project_name
  database_password = random_password.db.result
  region            = var.region

  lifecycle {
    # Prevent accidental destruction — the DB holds live data.
    prevent_destroy = true
    # Ignore provider-side drift on the password field (write-only after creation).
    ignore_changes = [database_password]
  }
}

locals {
  database_host = "db.${supabase_project.main.id}.supabase.co"
  database_url  = "postgresql://postgres:${random_password.db.result}@${local.database_host}:5432/postgres"
}

# Store the full connection URL in AWS Secrets Manager so EC2 can fetch it at runtime.
resource "aws_secretsmanager_secret" "database_url" {
  name                    = "${var.name_prefix}/database-url"
  description             = "Supabase PostgreSQL connection URL for the ${var.project_name} project."
  recovery_window_in_days = 7
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "database_url" {
  secret_id     = aws_secretsmanager_secret.database_url.id
  secret_string = local.database_url
}
