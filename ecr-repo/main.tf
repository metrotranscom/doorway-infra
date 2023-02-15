terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "doorway-state"
    key    = "ecr-repo/default"
    region = "us-west-1"
  }
}

provider "aws" {
  region = var.aws_region
}
