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

locals {
  # environment is set to workspace name if not explicitly set via var
  environment = var.environment != "default" ? var.environment : terraform.workspace

  # project scope is set based on is_production if not set to something other than "default" above
  scope = local.environment != "default" ? local.environment : var.is_production ? "prod" : "nonprod"

  # name_prefix is used to namespace resources based on a combination of project_id and scope
  name_prefix = "${var.project_id}-${local.scope}"
}
