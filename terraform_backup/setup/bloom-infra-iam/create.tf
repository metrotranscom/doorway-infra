
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

      # ECS - No resource ARNs permitted
      {
        Effect = "Allow"

        Action = [
          "ecs:CreateCluster",
          "ecs:CreateService",
          "ecs:RegisterTaskDefinition",
          #"ecs:TagResource"
        ]

        Resource  = "*"
        Condition = local.default_create_condition
      },

      # ECS tagging
      {
        Effect = "Allow"

        Action = [
          "ecs:TagResource"
        ]

        # Resource = [
        #   "arn:aws:ecs:${var.infra_region}:${var.infra_account_id}:cluster/${local.arn_resource_prefix}*",
        #   "arn:aws:ecs:${var.infra_region}:${var.infra_account_id}:task-definition/${local.arn_resource_prefix}*",
        # ]
        Resource = "*"
        Condition = merge(
          local.default_create_condition,
          {
            "StringEquals" : {
              # Permit tagging during these creation actions
              "ecs:CreateAction" : [
                "ecs:CreateCluster",
                "ecs:CreateService",
              ]
            }
          }
        )
      },

      # Elastic Load Balancing
      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:AddTags"
        ]

        Resource = "arn:aws:elasticloadbalancing:${var.infra_region}:${var.infra_account_id}:loadbalancer/app/${local.arn_resource_prefix}*"
        #Condition = local.default_create_condition
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
          "iam:CreatePolicy"
        ]

        Resource  = "*"
        Condition = local.default_create_condition
      },

      # IAM apply tags to new resources
      {
        Effect = "Allow"

        Action = [
          "iam:TagRole",
          "iam:UntagRole",
          "iam:TagPolicy",
          "iam:UntagPolicy"
        ]

        Resource = [
          # Roles
          "arn:aws:iam::${var.infra_account_id}:role/${local.arn_resource_prefix}*",

          # Policies
          "arn:aws:iam::${var.infra_account_id}:policy/${local.arn_resource_prefix}*"
        ]
      },

      # IAM PassRole
      # Required for passing roles to other services to use
      {
        Effect = "Allow"

        Action = [
          "iam:PassRole"
        ]

        # This should probably be just roles prefixed with a known good value
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

        #Resource  = "*"
        Resource  = "arn:aws:secretsmanager:${var.infra_region}:${var.infra_account_id}:secret:${local.arn_resource_prefix}*"
        Condition = local.default_create_condition
      },

      # Secrets Manager - Create inital tags on untagged secrets
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:TagResource"
        ]

        Resource = "arn:aws:secretsmanager:${var.infra_region}:${var.infra_account_id}:secret:${local.arn_resource_prefix}*"
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
