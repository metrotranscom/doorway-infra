terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "doorway-state"
    key    = "state/tf-pipeline.tfstate"
    region = "us-west-1"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags { tags = local.default_tags }
}


locals {
  name_prefix             = var.project_id
  qualified_name_prefix   = "${local.name_prefix}-${terraform.workspace}"
  codestar_connection_arn = var.codestar_connection_arn

  default_tags = {
    Owner     = var.owner
    Project   = var.project_name
    ProjectID = var.project_id
    Workspace = terraform.workspace
  }
}

module "pipeline" {
  source = "./pipeline"

  name                    = var.pipeline.name
  name_prefix             = local.qualified_name_prefix
  codestar_connection_arn = local.codestar_connection_arn

  tf_root             = var.pipeline.tf_root
  sources             = var.pipeline.sources
  environments        = var.pipeline.environments
  notification_topics = var.pipeline.notification_topics
  notification_rules  = var.pipeline.notify
}
