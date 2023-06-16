
resource "aws_iam_policy" "modify" {
  name = "${local.qualified_name}-modify"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Application AutoScaling for Fargate services
      {
        Effect = "Allow"

        Action = [
          "application-autoscaling:DeregisterScalableTarget",
          "application-autoscaling:DeleteScalingPolicy",
          "application-autoscaling:TagResource"
        ]

        Resource  = "*"
        Condition = local.default_modify_condition
      },
    ],
  })
}
