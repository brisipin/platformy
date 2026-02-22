terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
  backend "s3" {
    bucket  = "staging-terraform-state-12093"
    key     = "prod/doks/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}

data "aws_secretsmanager_secret_version" "do_token" {
  secret_id = "staging/do-api-token"
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

provider "digitalocean" {
  token = data.aws_secretsmanager_secret_version.do_token.secret_string
}

module "doks" {
  source = "../../../modules/doks"

  cluster_name   = "prod-doks"
  region         = "nyc1"
  node_pool_size = "s-1vcpu-2gb"
  node_count     = 1
  tags           = ["prod", "doks"]
}
