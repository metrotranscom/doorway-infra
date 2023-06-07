
locals {
  qualified_name    = "${var.name_prefix}-${var.name}"
  secret_arn_values = values(var.secret_arns)
  has_secrets       = length(local.secret_arn_values) > 0

  # var.secret_arn represents key-value pairs of secret ARNS that need to be
  # passed in as env vars for use in the "secrets-manager" section of the buildspec
  # Go ahead and add them to the env vars so they can be populated
  env_vars = merge(
    var.env_vars,
    var.secret_arns
  )

  use_network     = var.vpc.use
  vpc_id          = var.vpc.vpc_id
  subnets         = var.vpc.subnets
  security_groups = var.vpc.security_groups
  subnet_arns     = [for subnet in local.subnets : "arn:aws:ec2:*:*:subnet/${subnet}"]
}

resource "aws_codebuild_project" "project" {
  name          = local.qualified_name
  description   = "Deployment for ${var.name_prefix} into environment ${var.name}"
  build_timeout = var.timeout
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.compute_type
    image                       = var.image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = var.privileged

    dynamic "environment_variable" {
      for_each = local.env_vars
      iterator = env_var

      content {
        name  = env_var.key
        value = env_var.value
      }
    }
  }

  dynamic "vpc_config" {
    # Only create a vpc_config block if var.vpc.use == true
    for_each = [for vpc in [var.vpc] : vpc if vpc.use]

    content {
      vpc_id             = var.vpc.vpc_id
      subnets            = var.vpc.subnets
      security_group_ids = var.vpc.security_groups
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }
}

resource "aws_iam_role" "codebuild" {
  name = local.qualified_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Permit CodeBuild to assume this role
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}
