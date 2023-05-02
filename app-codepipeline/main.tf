terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.64"
    }
  }

  backend "s3" {
    bucket = "doorway-state"
    key    = "state/cicd.tfstate"
    region = "us-west-1"
  }
}

provider "aws" {
  region = var.aws_region
}
