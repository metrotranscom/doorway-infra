terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
      Application = local.application_name
      Project     = var.project_name
      ProjectId   = var.project_id
      Workspace   = terraform.workspace
      Environment = local.environment
    }
  }
}

# Needed to resolve current AWS Account ID for policy documents
data "aws_caller_identity" "current" {}

locals {
  # environment is set to workspace name if not explicitly set via var
  environment = var.environment != "default" ? var.environment : terraform.workspace

  # name_prefix is used to namespace resources based on a combination of project_id and scope
  name_prefix = "${var.project_id}-${local.environment}"

  #The ID for the Account that our resources are being deployed into
  current_account_id = data.aws_caller_identity.current.account_id

  application_name = "Base Infra"
}

module "repos" {
  for_each = { for name, repo in var.repos : name => repo }
  source   = "./ecr"

  name_prefix    = local.name_prefix
  name           = each.key
  scan_images    = each.value.scan_images
  source_account = each.value.source_account != null ? each.value.source_account : local.current_account_id
}

# Create IAm roles and policies for deploying Bloom infra
module "bloom-infra-iam" {
  source = "./bloom-infra-iam"

  name_prefix      = local.name_prefix
  project_id       = var.project_id
  environment      = local.environment
  infra_account_id = local.current_account_id
  infra_region     = var.aws_region
}
