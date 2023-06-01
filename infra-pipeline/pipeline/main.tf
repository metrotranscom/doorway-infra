
locals {
  codestar_connection_arn = var.codestar_connection_arn
  name_prefix             = var.name_prefix

  source_artifacts = keys(var.sources)

  # We have validation to make sure there is only one primary source
  primary_sources = [for name, source in var.sources : name if source.is_primary]
  primary_source  = local.primary_sources[0]

  notification_topic_arns = [for approval in module.approvals : approval.topic_arn]

  cloudbuild_src_dir_var = "CODEBUILD_SRC_DIR"

  # If the tf_root is in the primary source, the path to it is in the CODEBUILD_SRC_DIR env var
  # Otherwise it is in the var prefixed with "CODEBUILD_SRC_DIR_" and ending with the name of the source
  tf_root_var_name = (
    var.tf_root.source == local.primary_source
    ? local.cloudbuild_src_dir_var
    : "${local.cloudbuild_src_dir_var}_${var.tf_root.source}"
  )

  plan_file_artifact_name = "plan"
}

module "plan" {
  source = "./codebuild"

  for_each = { for env in var.environments : env.name => merge(env.plan, { workspace = env.workspace }) }

  name_prefix    = local.name_prefix
  name           = "${each.key}-plan"
  buildspec_path = "infra-pipeline/buildspec/plan.yaml"

  policy_arns = toset(concat(
    each.value.policy_arns,
    # Add policies we know will be needed
    [aws_iam_policy.codebuild_artifacts.arn]
  ))

  env_vars = merge(
    each.value.env_vars,
    {
      # This var is used by terraform to determine which workspace to use
      TF_WORKSPACE = each.value.workspace

      # We use this to indicate which var holds the path to the tfvars file
      TFVARS_SOURCE_VAR_NAME = (
        each.value.var_file.source == local.primary_source
        ? local.cloudbuild_src_dir_var
        : "${local.cloudbuild_src_dir_var}_${each.value.var_file.source}"
      )

      # The path to the var file in that source
      TFVARS_PATH = each.value.var_file.path

      # We use this to indicate which var holds the path to the TF root
      TF_ROOT_SOURCE_VAR_NAME = local.tf_root_var_name

      # And this tells us where under the TF root source to actually run the terraform commands
      TF_ROOT_PATH = var.tf_root.path
    }
  )

  depends_on = [aws_iam_policy.codebuild_artifacts]
}

module "apply" {
  source = "./codebuild"

  #for_each = { for env in var.environments : env.name => env }
  for_each = { for env in var.environments : env.name => merge(env.apply, { workspace = env.workspace }) }

  name_prefix    = local.name_prefix
  name           = "${each.key}-apply"
  buildspec_path = "infra-pipeline/buildspec/apply.yaml"

  policy_arns = toset(concat(
    each.value.policy_arns,
    # Add policies we know will be needed
    [aws_iam_policy.codebuild_artifacts.arn]
  ))

  env_vars = merge(
    each.value.env_vars,
    {
      # This var is used by terraform to determine which workspace to use
      TF_WORKSPACE = each.value.workspace

      # We use this to indicate which var holds the path to the TF root
      TF_ROOT_SOURCE_VAR_NAME = local.tf_root_var_name

      # And this tells us where under the TF root source to actually run the terraform commands
      TF_ROOT_PATH = var.tf_root.path

      # We use this to indicate which var holds the path to the artifact for the plan file
      TF_PLAN_SOURCE_VAR_NAME = "${local.cloudbuild_src_dir_var}_${local.plan_file_artifact_name}"

      # This holds the relative path to the plan file
      TF_PLAN_PATH = "plan.out"
    }
  )

  depends_on = [aws_iam_policy.codebuild_artifacts]
}

module "approvals" {
  source = "./approval"

  # Only create approval topics for stages that need it
  for_each = { for env in var.environments : env.name => env.approval if try(env.approval.required, false) }

  name_prefix = local.name_prefix
  name        = each.key
  emails      = each.value.approvers
}

resource "aws_codepipeline" "pipeline" {
  name     = var.name
  role_arn = aws_iam_role.pipeline.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    dynamic "action" {
      for_each = var.sources

      content {
        name             = action.value.name
        category         = "Source"
        owner            = "AWS"
        provider         = "CodeStarSourceConnection"
        version          = "1"
        output_artifacts = [action.key]

        configuration = {
          ConnectionArn    = local.codestar_connection_arn
          FullRepositoryId = action.value.repo.name
          BranchName       = action.value.repo.branch
        }
      }
    }
  }

  dynamic "stage" {
    for_each = var.environments

    content {
      name = "Deploy-${stage.value.name}"

      action {
        name             = "Plan"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        version          = "1"
        input_artifacts  = local.source_artifacts
        output_artifacts = [local.plan_file_artifact_name]
        run_order        = 1

        configuration = {
          ProjectName   = module.plan[stage.value.name].name
          PrimarySource = local.primary_source
        }
      }

      # The "Test" action for running static code analysis goes here

      # If we need manual approval, it goes after determining what changes need
      # to be made (and optionally doing some security analysis) and applying
      # those changes
      dynamic "action" {
        for_each = local.notification_topic_arns

        content {
          name      = "Approve-Deployment"
          category  = "Approval"
          owner     = "AWS"
          provider  = "Manual"
          version   = "1"
          run_order = 3

          configuration = {
            NotificationArn = action.value
          }
        }
      }

      action {
        name     = "Apply"
        category = "Build"
        owner    = "AWS"
        provider = "CodeBuild"
        version  = "1"
        # Add plan file from "Plan" action to input artifacts
        input_artifacts = concat(local.source_artifacts, [local.plan_file_artifact_name])
        run_order       = 4

        configuration = {
          ProjectName   = module.apply[stage.value.name].name
          PrimarySource = local.primary_source
        }
      }
    }
  }
}
