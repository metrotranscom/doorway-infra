
resource "aws_iam_policy" "create" {
  name = "${local.qualified_name}-create"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Application AutoScaling for Fargate services
      {
        Effect = "Allow"

        Action = [
          "application-autoscaling:RegisterScalableTarget",
          "application-autoscaling:PutScalingPolicy"
        ]

        Resource = "*"
        # Add condition?
        #Condition = local.default_create_condition
      },

      # EventBridge Scheduler
      {
        Effect = "Allow"

        Action = [
          "scheduler:CreateSchedule",
          # TODO: Move to modify
          "scheduler:UpdateSchedule",
          "scheduler:DeleteSchedule"
        ]

        Resource = "*"
        # Add condition?
        #Condition = local.default_create_condition
      },

      # ECS
      {
        Effect = "Allow"

        Action = [
          "ecs:CreateCluster",
          "ecs:CreateService",
          "ecs:RegisterTaskDefinition"
        ]

        Resource  = "*"
        Condition = local.default_create_condition
      },

      # Elastic Load Balancing
      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:CreateRule"
        ]

        Resource  = "*"
        Condition = local.default_create_condition
      },

      # Amazon Certificate Manager
      {
        Effect = "Allow"

        Action = [
          "acm:RequestCertificate",
          "acm:AddTagsToCertificate"
        ]

        Resource  = "*"
        Condition = local.default_create_condition
      },

      # IAM
      {
        Effect = "Allow"

        Action = [
          "iam:CreateRole",
          "iam:CreatePolicy",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:TagPolicy",
          "iam:UntagPolicy"
        ]

        Resource  = "*"
        Condition = local.default_create_condition
      },

      # Secrets Manager
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:CreateSecret"
        ]

        Resource  = "*"
        Condition = local.default_create_condition
      },

      # Route 53
      # Unfortunately, it isn't possible to scope Route 53 access using tags
      # Nor is it possible to create scoped permissions for zones that don't exist yet
      {
        Effect = "Allow"

        Action = [
          # Change can mean both create and modify
          "route53:ChangeResourceRecordSets"
        ]

        Resource = "*"
      },
    ],
  })
}
