# The brackets app has been torn down. This root is intentionally empty so the
# next apply destroys everything left in its state. Once that apply succeeds,
# delete this directory and the staging-brackets-app jobs in
# .github/workflows/staging_plan.yml and staging_apply.yml.
# The Supabase project (env/staging/supabase) is kept.

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
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket  = "staging-terraform-state-12093"
    key     = "staging/brackets-app/terraform.tfstate"
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
