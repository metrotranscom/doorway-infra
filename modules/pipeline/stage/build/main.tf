
locals {
  qualified_name = "${var.name_prefix}-${var.name}"
  buildspec_path = var.buildspec.path
}

resource "aws_codebuild_project" "project" {
  name          = local.qualified_name
  description   = "Deployment for ${var.name_prefix} into environment ${var.name}"
  build_timeout = var.build_timeout
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.compute_type
    image                       = var.image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    dynamic "environment_variable" {
      for_each = var.env_vars
      iterator = env_var

      content {
        name  = env_var.key
        value = env_var.value
      }
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = local.buildspec_path
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

resource "aws_iam_role_policy_attachment" "supplied" {
  for_each   = var.policy_arns
  role       = aws_iam_role.codebuild.name
  policy_arn = each.value
}

resource "aws_iam_policy" "write_logs" {
  name = "${local.qualified_name}-logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowWriteLogs"
        Effect = "Allow"

        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
        ]

        Resource = [
          "arn:aws:logs:*:*:log-group:/aws/codebuild/${local.qualified_name}:log-stream:*"
        ]
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "write_logs" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.write_logs.arn
}
