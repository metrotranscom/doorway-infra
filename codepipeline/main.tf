terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "doorway-cicd-state"
    key    = "state/cicd.tfstate"
    region = "us-west-1"
  }
}

provider "aws" {
  region = var.aws_region
}
