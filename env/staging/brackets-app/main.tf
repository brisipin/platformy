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

variable "github_app_repositories" {
  type        = list(string)
  default     = ["brisipin/brackets"]
  description = "Repos that may assume the ECR push role."
}

variable "create_github_oidc_provider" {
  type        = bool
  default     = true
  description = "Create GitHub OIDC provider in this account (once). Set false if it already exists; then use github_oidc_provider_arn or rely on data lookup."
}

variable "github_oidc_provider_arn" {
  type        = string
  default     = ""
  description = "Use existing OIDC provider ARN instead of create or data lookup."
}

variable "budget_alert_emails" {
  type        = list(string)
  default     = ["bsipin@gmail.com"]
  description = "Emails for monthly AWS Budget alerts; confirm subscription in inbox. Override in tfvars if needed."
}

variable "budget_monthly_usd" {
  type        = number
  default     = 50
  description = "Monthly budget threshold in USD."
}

module "brackets_app" {
  source = "../../../modules/brackets-app"

  name_prefix   = "brackets-staging"
  ecr_image_tag = "latest"

  github_actions_ecr_push_repositories = var.github_app_repositories
  create_github_oidc_provider = var.create_github_oidc_provider
  github_oidc_provider_arn    = var.github_oidc_provider_arn

  budget_alert_emails  = var.budget_alert_emails
  budget_monthly_usd   = var.budget_monthly_usd

  tags = {
    App = "brackets"
  }
}
