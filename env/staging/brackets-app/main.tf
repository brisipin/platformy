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
  default     = []
  description = "Repos that may assume the ECR push role, e.g. [\"myorg/my-backend\"]."
}

variable "create_github_oidc_provider" {
  type        = bool
  default     = false
  description = "Set true once per AWS account if GitHub OIDC provider is not created yet."
}

variable "github_oidc_provider_arn" {
  type        = string
  default     = ""
  description = "Use existing OIDC provider ARN instead of create or data lookup."
}

module "brackets_app" {
  source = "../../../modules/brackets-app"

  name_prefix   = "brackets-staging"
  ecr_image_tag = "latest"

  github_actions_ecr_push_repositories = var.github_app_repositories
  create_github_oidc_provider          = var.create_github_oidc_provider
  github_oidc_provider_arn             = var.github_oidc_provider_arn

  tags = {
    App = "brackets"
  }
}
