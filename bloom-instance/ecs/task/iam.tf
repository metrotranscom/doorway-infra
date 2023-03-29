
resource "aws_iam_role" "task_exec" {
  name = "${local.default_name}-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Permit ECS to assume this role
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.additional_tags
}

resource "aws_iam_policy" "logs" {
  name = "${local.default_name}-logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowWriteLogsToCloudWatch"
        Effect = "Allow"

        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]

        # TODO: restrict to specific log group/stream
        Resource = "arn:aws:logs:::log-group:*:log-stream:*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.task_exec.name
  policy_arn = aws_iam_policy.logs.arn
}

resource "aws_iam_policy" "ecr_read" {
  count = local.is_ecr ? 1 : 0

  name        = "${local.default_name}-ecr-read"
  description = "Read access to related ECR repo"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowImagePull"
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:ListImages",
        ]

        Resource = "arn:aws:ecr:${local.ecr_repo.region}:${local.ecr_repo.account}:repository/${local.ecr_repo.repo}"
      },
      {
        Sid    = "AllowAuth"
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken",
        ]

        # This permission cannot be scoped to a specific resource
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  count = local.is_ecr ? 1 : 0

  role       = aws_iam_role.task_exec.name
  policy_arn = aws_iam_policy.ecr_read[0].arn
}
