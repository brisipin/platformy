terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    supabase = {
      source  = "supabase/supabase"
      version = "~> 1.0"
    }
  }

  # Shares the one state bucket (named for staging); the key keeps prod apart.
  backend "s3" {
    bucket  = "staging-terraform-state-12093"
    key     = "prod/affine/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      Environment = "prod"
      ManagedBy   = "OpenTofu"
    }
  }
}

# Supplied via TF_VAR_supabase_access_token GitHub Actions secret.
variable "supabase_access_token" {
  type        = string
  sensitive   = true
  description = "Supabase personal access token (supabase.com/dashboard/account/tokens)."
}

# Supplied via TF_VAR_supabase_organization_id GitHub Actions secret.
variable "supabase_organization_id" {
  type        = string
  description = "Supabase organization ID."
}

provider "supabase" {
  access_token = var.supabase_access_token
}

# Postgres for self-hosted AFFiNE (deployed from brisipin/helm-charts).
# AFFiNE's own migrations create the pgvector and pgcrypto extensions.
module "supabase" {
  source = "../../../modules/supabase"

  name_prefix     = "affine-prod"
  organization_id = var.supabase_organization_id
  project_name    = "affine-prod"
  region          = "us-east-1"

  tags = {
    App = "affine"
  }
}

# The direct host (db.<ref>.supabase.co) is IPv6-only and the Rackspace Spot
# nodes are IPv4, so AFFiNE connects through the pooler instead. Session mode
# (port 5432) rather than transaction mode (6543): Prisma migrations and
# prepared statements need a session.
data "supabase_pooler" "main" {
  project_ref = module.supabase.project_ref
}

locals {
  pooler_host = regex("@([^:/]+)", values(data.supabase_pooler.main.url)[0])[0]
  pooler_url  = "postgresql://postgres.${module.supabase.project_ref}:${module.supabase.database_password}@${local.pooler_host}:5432/postgres"
}

resource "aws_secretsmanager_secret" "pooler_url" {
  name                    = "affine-prod/database-url-pooler"
  description             = "Supabase session-pooler (IPv4) PostgreSQL URL for AFFiNE. Use as DATABASE_URL."
  recovery_window_in_days = 7
  tags = {
    App = "affine"
  }
}

resource "aws_secretsmanager_secret_version" "pooler_url" {
  secret_id     = aws_secretsmanager_secret.pooler_url.id
  secret_string = local.pooler_url
}
