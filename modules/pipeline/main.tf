
locals {
  codestar_connection_arn = var.codestar_connection_arn
  name_prefix             = var.name_prefix
  qualified_name          = "${var.name_prefix}-${var.name}"

  source_artifacts = keys(var.sources)

  # We have validation to make sure there is only one primary source
  primary_sources = [for name, source in var.sources : name if source.is_primary]
  primary_source  = local.primary_sources[0]

  #notification_topic_arns = [for approval in module.approvals : approval.topic_arn]
  # Filter out which stages require approval before deployment
  # approvals = { for env in var.environments : env.name => env.approval.topic if try(env.approval.required, false) }
  # # Map the topic ARNs for those stages
  # approval_topic_arn_map = { for stage, topic in local.approvals : stage => module.notification_topic[topic].topic_arn }
  # # And get just the ARNs for IAM policies
  # approval_topic_arn_list = values(local.approval_topic_arn_map)
  # # Boolean value for simple checks
  # have_approvals = length(local.approval_topic_arn_list) > 0

  # The env var used in CodeBuild to point to the source root
  cloudbuild_src_dir_var = "CODEBUILD_SRC_DIR"

  # If the tf_root is in the primary source, the path to it is in the CODEBUILD_SRC_DIR env var
  # Otherwise it is in the var prefixed with "CODEBUILD_SRC_DIR_" and ending with the name of the source
  # tf_root_var_name = (
  #   var.tf_root.source == local.primary_source
  #   ? local.cloudbuild_src_dir_var
  #   : "${local.cloudbuild_src_dir_var}_${var.tf_root.source}"
  # )

  #plan_file_artifact_name = "plan"
}

module "stages" {
  source   = "./stage"
  for_each = { for stage in var.stages : stage.name => stage }

  name        = each.key
  name_prefix = local.qualified_name

  actions = each.value.actions
}

module "notification_topic" {
  source = "./notification/topic"

  for_each = var.notification_topics

  name_prefix = local.name_prefix
  name        = each.key
  emails      = each.value.emails
}

module "notification_rules" {
  source = "./notification/rule/pipeline"

  for_each = { for idx, rule in var.notification_rules : idx => rule }

  name_prefix = local.name_prefix
  name        = "${each.value.topic}${each.key}"

  topic_arn    = module.notification_topic[each.value.topic].topic_arn
  pipeline_arn = aws_codepipeline.pipeline.arn
  detail       = each.value.detail
  events       = each.value.on
}

resource "aws_codepipeline" "pipeline" {
  name     = local.qualified_name
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
    for_each = module.stages

    content {
      name = stage.key

      # action {
      #   name             = "Plan"
      #   category         = "Build"
      #   owner            = "AWS"
      #   provider         = "CodeBuild"
      #   version          = "1"
      #   input_artifacts  = local.source_artifacts
      #   output_artifacts = [local.plan_file_artifact_name]
      #   run_order        = 1

      #   configuration = {
      #     ProjectName   = module.plan[stage.value.name].name
      #     PrimarySource = local.primary_source
      #   }
      # }

      # Build actions
      dynamic "action" {
        for_each = stage.value.build_actions

        content {
          name            = action.key
          category        = "Build"
          owner           = "AWS"
          provider        = "CodeBuild"
          version         = "1"
          input_artifacts = local.source_artifacts
          run_order       = action.value.order

          configuration = {
            ProjectName   = action.value.project_name
            PrimarySource = local.primary_source
          }
        }
      }

      # Approval actions
      # dynamic "action" {
      #   #for_each = try([local.approval_topic_arn_map[stage.value.name]], [])
      #   for_each = try([local.approval_topic_arn_map[stage.value.name]], [])

      #   content {
      #     name      = "Approve-Deployment"
      #     category  = "Approval"
      #     owner     = "AWS"
      #     provider  = "Manual"
      #     version   = "1"
      #     run_order = 3

      #     configuration = {
      #       NotificationArn = action.value
      #     }
      #   }
      # }
    }
  }
}
