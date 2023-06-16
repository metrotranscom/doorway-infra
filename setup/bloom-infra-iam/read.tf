

resource "aws_iam_policy" "read" {
  name = "${local.qualified_name}-read"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Required for VPC
      {
        Effect = "Allow"

        Action = [
          "ec2:DescribeRouteTables"
        ]

        Resource = "*"
      },

      # Application AutoScaling for Fargate services
      {
        Effect = "Allow"

        Action = [
          "application-autoscaling:DescribeScalableTargets",
          "application-autoscaling:DescribeScalingPolicies"
        ]

        Resource = "*"
      },
    ],
  })
}
