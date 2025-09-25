
locals {
  codestar_connection_arn = var.codestar_connection_arn
  name_prefix             = var.name_prefix
  qualified_name          = "${var.name_prefix}-${var.name}"

  source_artifacts = keys(var.sources)

  # We have validation to make sure there is only one primary source
  primary_sources = [for name, source in var.sources : name if source.is_primary]
  primary_source  = local.primary_sources[0]

  # Set type-appropriate empty values if not set
  build_policy_arns = var.build_policy_arns != null ? var.build_policy_arns : []
  build_env_vars    = var.build_env_vars != null ? var.build_env_vars : {}

  # Get a list of all approval topic ARNS
  approval_topic_arn_list = concat([
    for stage in module.stages : [for action in stage.approval_actions : action.topic_arn]
  ]...)

  # Convert to a set of unique values
  approval_topic_arn_set = toset(local.approval_topic_arn_list)

  # Boolean value for simple checks
  have_approvals = length(local.approval_topic_arn_set) > 0
}

module "stages" {
  source   = "./stage"
  for_each = { for stage in var.stages : stage.name => stage }

  name        = each.key
  label       = each.value.label == null ? each.key : each.value.label
  name_prefix = local.qualified_name

  #actions = each.value.actions
  build_actions    = [for action in each.value.actions : action if action.type == "build"]
  approval_actions = [for action in each.value.actions : action if action.type == "approval"]

  default_network = each.value.default_network

  build_policy_arns = setunion(
    # Pipeline-level policies
    local.build_policy_arns,
    # Stage-level policies in config
    each.value.build_policy_arns,
    #each.value.build_policy_arns != null ? each.value.build_policy_arns : [],
    # The policy that enables reading from the artifact store
    [aws_iam_policy.codebuild_artifacts.arn]
  )

  build_env_vars = merge(
    # Pipeline-level env vars
    local.build_env_vars,
    # Stage-level env vars
    #each.value.build_env_vars != null ? each.value.build_env_vars : {}
    each.value.build_env_vars
  )

  notification_topics = module.notification_topic
}

module "notification_topic" {
  source = "./notification/topic"

  for_each = var.notification_topics

  name_prefix = local.qualified_name
  name        = each.key
  emails      = each.value.emails
}

module "notification_rules" {
  source = "./notification/rule/pipeline"

  for_each = { for idx, rule in var.notification_rules : idx => rule }

  name_prefix = local.qualified_name
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
      name = stage.value.label

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
          name            = action.value.label
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
      dynamic "action" {
        for_each = stage.value.approval_actions

        content {
          name      = action.value.label
          category  = "Approval"
          owner     = "AWS"
          provider  = "Manual"
          version   = "1"
          run_order = action.value.order

          configuration = {
            NotificationArn = action.value.topic_arn
          }
        }
      }
    }
  }
}
