
locals {
  codestar_connection_arn = var.codestar_connection_arn
  name_prefix             = var.name_prefix

  source_artifacts = keys(var.sources)

  notification_topic_arns = [for approval in module.approvals : approval.topic_arn]
}

module "codebuild" {
  source = "./codebuild"

  for_each = { for env in var.environments : env.name => env }

  name_prefix = local.name_prefix
  name        = each.key
  policy_arns = toset(concat(
    each.value.policy_arns,
    # Add policies we know will be needed
    [aws_iam_policy.codebuild_artifacts.arn]
  ))

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
      name = "Deploy-${stage.value.name}-bloom-infra"

      dynamic "action" {
        for_each = [module.approvals[stage.value.name].topic_arn]

        content {
          name      = "Approve-Deployment"
          category  = "Approval"
          owner     = "AWS"
          provider  = "Manual"
          version   = "1"
          run_order = 1

          configuration = {
            NotificationArn = action.value
          }
        }
      }

      action {
        name            = "Plan"
        category        = "Build"
        owner           = "AWS"
        provider        = "CodeBuild"
        version         = "1"
        input_artifacts = local.source_artifacts
        run_order       = 2

        configuration = {
          ProjectName = module.codebuild[stage.value.name].name
        }
      }
    }
  }
}
