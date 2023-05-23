
resource "aws_iam_role" "scheduler_exec" {
  name = "${local.qualified_name_prefix}-schecduler-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Permit EventBridge to assume this role
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })

  tags = var.additional_tags
}

resource "aws_iam_policy" "run_task" {
  name = "${local.qualified_name_prefix}-run_task"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRunScheduledTask"
        Effect = "Allow"

        Action = [
          "ecs:RunTask",
        ]

        Resource = module.task.arn
      },
      # Permit EventBridge to pass roles to ECS
      {
        Sid      = "AllowPassRole"
        Action   = "iam:PassRole"
        Effect   = "Allow"
        Resource = module.task.exec_role_arn
        Condition = {
          StringLike = {
            "iam:PassedToService" : "ecs-tasks.amazonaws.com"
          }
        }
      }
    ],
  })
}

resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.scheduler_exec.name
  policy_arn = aws_iam_policy.run_task.arn
}
