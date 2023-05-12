resource "aws_codebuild_project" "partners" {
  name         = "${var.name_prefix}-codebuild-partners"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    dynamic "environment_variable" {
      for_each = local.build_env_vars
      content {
        name  = environment_variable.value["name"]
        value = environment_variable.value["value"]
      }
    }
  }

  vpc_config {
    vpc_id = var.codebuild_vpc_id
    subnets = var.codebuild_vpc_subnets
    security_group_ids = var.codebuild_vpc_sgs
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "ci/buildspec_partners.yml"
  }

  build_timeout = "120"
}
