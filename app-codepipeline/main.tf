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

locals {
  qualified_name = "${var.name_prefix}-${terraform.workspace}"

  # Use the current region if var.ecr.default_region is not set
  ecr_repo_default_region = (
    var.ecr.default_region == ""
    ? var.aws_region
    : var.ecr.default_region
  )

  # Use the current account if var.ecr.default_account is not set
  ecr_repo_default_account = (
    var.ecr.default_account == ""
    ? data.aws_caller_identity.current.account_id
    : var.ecr.default_account
  )
}

module "ecr_repos" {
  source = "./repo"
  #for_each = { for name, repo in var.ecr.repos : var}
  #for_each = var.ecr.repos

  for_each = merge([for group_name, group in var.ecr.repo_groups :
    { for repo in group.repos :
      "${group_name}:${repo}" => {
        name        = repo
        name_prefix = "${local.qualified_name}-${group_name}"
        region      = group.region == null ? local.ecr_repo_default_region : group.region
        account     = group.account == null ? local.ecr_repo_default_account : group.account
        namespace   = group.namespace
      }
    }
  ]...)

  name        = each.value.name
  name_prefix = each.value.name_prefix

  region    = each.value.region
  account   = each.value.account
  namespace = each.value.namespace
}

module "pipeline" {
  source = "../modules/pipeline"

  name                    = var.pipeline.name
  name_prefix             = local.qualified_name
  codestar_connection_arn = data.aws_codestarconnections_connection.default.arn

  sources             = var.pipeline.sources
  stages              = var.pipeline.stages
  notification_topics = var.pipeline.notification_topics
  notification_rules  = var.pipeline.notify
  build_policy_arns   = var.pipeline.build_policy_arns
  build_env_vars      = var.pipeline.build_env_vars
}
