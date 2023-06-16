
resource "aws_iam_policy" "create" {
  name = "${local.qualified_name}-create"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # S3 (does not support ABAC)
      {
        "Action" : [
          "s3:CreateBucket",
        ],
        "Effect" : "Allow",
        "Resource" : "${local.s3_bucket_arn}*"
      },

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

      # IAM PassRole
      # Required for passing roles to other services to use
      {
        Effect = "Allow"

        Action = [
          "iam:PassRole"
        ]

        # TODO: This should probably be just roles prefixed with a known good value
        # Note that there are valid use cases that may preclude this (passing AWS-managed roles, etc)
        Resource = "*"

        # Restrict to just the services we know we'll be using
        Condition = {
          StringEquals = {
            "iam:PassedToService" = local.pass_role_services
          }
        }
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
