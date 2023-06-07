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
  qualified_name = "${var.project_id}-${terraform.workspace}"

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

  # Here we can build a role/policy pair based on actions needing access to 
  # certain repos. These permissions would be added after the creation of the
  # pipeline via a aws_iam_role_policy_attachment resource.

  # ecr_repo_policy_attachments = concat([
  #   # For each stage in the pipeline...
  #   for stage in var.pipeline.stages : concat([
  #     # and each action in each stage..
  #     for action in stage.actions : concat([
  #       # See what permissions are needed in repo_iam...
  #       for repo_id, perms in action.ecr_repo_access : [
  #         for perm in perms : {
  #           action_role_arn = module.pipeline.stages[stage.name].build_actions[action.name].role_arn
  #           ecr_policy_arn  = module.ecr_repos[repo_id].policy_arns[perm]
  #         } if contains(["push", "pull"], perm)
  #       ]
  #     ]...) if action.ecr_repo_access != null
  #   ]...)
  # ]...)

  # Here we mutate stages/actions to add ecr repo permissions prior to pipeline creation

  # This could also be done after the pipeline is complete (see above), but is
  # included here as an example of how to modify the stages/actions prior to 
  # passing to the pipeline.  This approach can be used to inject env vars, etc.
  stages = concat([
    # For each stage...
    for stage in var.pipeline.stages : [
      # create a new stage object that combines the previous value...
      merge(
        stage,
        {
          # with another that has rewritten action values.
          actions = concat([
            # For each action that we have...
            for action in stage.actions : [
              merge(
                # combine the original action object...
                action,
                # with another that contains additional policies.
                {
                  # Combine any existing policy_arns...
                  policy_arns : concat(
                    try(action.policy_arns, []),
                    [
                      # with additional ones based on the values in ecr_repo_access
                      # Note that we use "try" because it might not be set on the action
                      for repo_id, perms in try(action.ecr_repo_access, {}) : concat([
                        for perm in perms : [
                          module.ecr_repos[repo_id].policy_arns[perm]
                        ] if contains(["push", "pull"], perm)
                      ]...) if try(action.ecr_repo_access, null) != null
                    ]...
                  )

                  # It would be possible to add/change some other action values here
                }
              )
            ]
          ]...)

          # It would be possible to add/change some other stage values here
        }
      )
    ]
  ]...)
}

# Needed to resolve current AWS Account ID
data "aws_caller_identity" "current" {}

# NOTE: Auth with the GitHub must be completed in the AWS Console.
data "aws_codestarconnections_connection" "default" {
  name = var.gh_codestar_conn_name
}

module "ecr_repos" {
  source = "./ecr_repo"

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

  sources = var.pipeline.sources
  #stages  = var.pipeline.stages
  stages              = local.stages
  notification_topics = var.pipeline.notification_topics
  notification_rules  = var.pipeline.notify
  build_policy_arns   = var.pipeline.build_policy_arns
  build_env_vars      = var.pipeline.build_env_vars
}

output "ecr_repos" {
  value = module.ecr_repos
}

output "pipeline" {
  value = module.pipeline
}
