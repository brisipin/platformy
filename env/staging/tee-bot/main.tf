terraform {
  required_version = ">= 1.6.0"

  required_providers {
    spot = {
      source = "rackerlabs/spot"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket  = "staging-terraform-state-12093"
    key     = "staging/tee-bot/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}

variable "rackspace_spot_token" {
  description = "Rackspace Spot authentication token"
  type        = string
  sensitive   = true
}

provider "spot" {
  token = var.rackspace_spot_token
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

module "tee_bot" {
  source = "../../../modules/tee-bot"

  github_actions_ecr_push_repositories = ["brisipin/sass-bot"]

  tags = {
    App = "tee-bot"
  }
}
