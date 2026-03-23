terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

module "staging_backend" {
  source = "../modules/opentofu-backend"

  environment = "staging"
  bucket_name = "staging-terraform-state-12093"
}

