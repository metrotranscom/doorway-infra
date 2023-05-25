
# resource "aws_codebuild_project" "deploy" {
#   for_each = { for env in var.environments : env.name => env }

#   name          = "${local.name_prefix}-build-${each.key}"
#   description   = "Deployment for ${local.name_prefix} into environment ${each.key}"
#   build_timeout = 60
#   service_role  = each.value.role_arn

#   artifacts {
#     type = "CODEPIPELINE"
#   }

#   environment {
#     compute_type                = "BUILD_GENERAL1_SMALL"
#     image                       = "aws/codebuild/standard:6.0"
#     type                        = "LINUX_CONTAINER"
#     image_pull_credentials_type = "CODEBUILD"
#   }

#   source {
#     type      = "CODEPIPELINE"
#     buildspec = "infra-pipeline/buildspec.yaml"
#   }

#   logs_config {
#     cloudwatch_logs {
#       status = "ENABLED"
#     }
#   }
# }
