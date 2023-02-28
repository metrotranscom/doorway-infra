terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "doorway-state"
    key    = "state/setup.tfstate"
    region = "us-west-1"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project    = var.project_name
      Workspace  = terraform.workspace
      Production = var.is_production ? "true" : "false"
    }
  }
}
