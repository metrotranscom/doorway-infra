
resource "aws_iam_policy" "create" {
  name = "${local.qualified_name}-create"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Required for VPC
      {
        Effect = "Allow"

        Action = [
          "application-autoscaling:RegisterScalableTarget",
          "application-autoscaling:PutScalingPolicy"
        ]

        Resource = "*"
      },
    ],
  })
}
