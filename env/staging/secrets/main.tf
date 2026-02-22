terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket  = "staging-terraform-state-12093"
    key     = "staging/secrets/terraform.tfstate"
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

variable "do_token" {
  type        = string
  default     = ""
  sensitive   = true
  description = "DigitalOcean API token. Set via TF_VAR_do_token for initial secret value, or leave empty and set value later in AWS Console/CLI."
}

module "do_token" {
  source = "../../../modules/secrets"

  secret_name   = "staging/do-api-token"
  description   = "DigitalOcean API token for staging (used by DOKS, Droplets, etc.)."
  secret_string = var.do_token
  tags          = {}
}
