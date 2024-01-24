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
# This provider is to create the certs in us-east-1 so that it can be used by cloudfront
provider "aws" {
  region = "us-east-1"
  alias = "use1"
  default_tags { tags = local.default_tags }
}
variable "s3_force_destroy" {
  type    = bool
  default = false
}
# Needed to resolve current AWS Account ID for policy documents
data "aws_caller_identity" "current" {}

# ELBs have special rules for granting access for logging purposes
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
data "aws_elb_service_account" "current" {}

locals {
  # This level of indirection helps when refactoring widely-used vars
  project_id = var.project_id

  # We may want to rearrange the order of these in the future based on how easy
  # or hard it is to read at a glance in the console.
  qualified_name_prefix = "${local.project_id}-${terraform.workspace}"

  default_tags = {
    Owner       = var.owner
    Project     = var.project_name
    ProjectID   = local.project_id
    Application = var.application_name
    Environment = var.environment
    Workspace   = terraform.workspace
  }

  #The ID for the Account that our resources are being deployed into
  current_account_id = data.aws_caller_identity.current.account_id

  # The Account ID for the AWS ELB service in this region
  elb_service_account_arn = data.aws_elb_service_account.current.arn

  # Defining this here ensures that all of our task logs get grouped together
  task_log_group_name = "${local.qualified_name_prefix}-tasks"

  cert_map = { for name, cert in module.certs : name => cert.arn }
}

# The default cluster for all ECS tasks and services
resource "aws_ecs_cluster" "default" {
  name = "${local.qualified_name_prefix}-default"
}

module "dns" {
  source = "./dns"
  dns    = var.dns
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
