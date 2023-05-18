terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.57.0"
    }
  }

  backend "s3" {
    bucket = "doorway-state"
    key    = "bloom/default"
    region = "us-west-1"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags { tags = local.default_tags }
}


# Needed to resolve current AWS Account ID for policy documents
data "aws_caller_identity" "current" {}

# ELBs have special rules for granting access for logging purposes
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
data "aws_elb_service_account" "current" {}

locals {
  # We may want to rearrange the order of these in the future based on how easy
  # or hard it is to read at a glance in the console.
  qualified_name_prefix = "${var.name_prefix}-${terraform.workspace}"

  # Alias the old name so it can be removed later
  default_name = local.qualified_name_prefix

  default_tags = {
    Team        = var.team_name
    Project     = var.project_name
    Application = var.application_name
    Environment = var.sdlc_stage
    Workspace   = terraform.workspace
  }

  #The ID for the Account that our resources are being deployed into
  current_account_id = data.aws_caller_identity.current.account_id

  # The Account ID for the AWS ELB service in this region
  elb_service_account_arn = data.aws_elb_service_account.current.arn

  task_log_group_name = "${local.default_name}-tasks"
}

# The default cluster for all ECS tasks and services
resource "aws_ecs_cluster" "default" {
  name = "${local.default_name}-default"
}

# A cloudwatch log group for all tasks
resource "aws_cloudwatch_log_group" "tasks" {
  name = local.task_log_group_name
}

# inform terraform about renamed network resources
moved {
  from = module.network.module.public
  to   = module.network.module.public_subnet_group
}

moved {
  from = module.network.module.app
  to   = module.network.module.private_subnet_groups["app"]
}

moved {
  from = module.network.module.data
  to   = module.network.module.private_subnet_groups["data"]
}
