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

  backend "s3" {
    bucket  = "staging-terraform-state-12093"
    key     = "staging/supabase/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      Environment = "staging"
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
# Find at: supabase.com/dashboard/org/<slug>/settings — the ID in the URL.
variable "supabase_organization_id" {
  type        = string
  description = "Supabase organization ID."
}

provider "supabase" {
  access_token = var.supabase_access_token
}

module "supabase" {
  source = "../../../modules/supabase"

  name_prefix     = "brackets-staging"
  organization_id = var.supabase_organization_id
  project_name    = "brackets-staging"
  region          = "us-east-1"

  tags = {
    App = "brackets"
  }
}
