

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

      # S3 (does not support ABAC)
      {
        "Action" : [
          "s3:GetBucket*",
        ],
        "Effect" : "Allow",
        "Resource" : "${local.s3_bucket_arn}*"
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

      # EventBridge Scheduler
      {
        Effect = "Allow"

        Action = [
          "scheduler:ListSchedules",
          "scheduler:GetSchedule"
        ]

        Resource = "*"
      },

      # ECS
      {
        Effect = "Allow"

        Action = [
          "ecs:DescribeClusters",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListClusters",
          "ecs:ListServices",
          "ecs:ListTaskDefinitions",
          "ecs:ListTagsForResource",
        ]

        Resource = "*"
      },

      # Elastic Load Balancing
      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeListenerCertificates",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetHealth",
          # TODO: move to modify
          "elasticloadbalancing:RemoveTags"
        ]

        Resource = "*"
      },

      # Amazon Certificate Manager
      {
        Effect = "Allow"

        Action = [
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          "acm:ListTagsForCertificate",
          #"acm:DeleteCertificate",
          #"acm:AddTagsToCertificate"
        ]

        Resource = "*"
      },

      # Amazon Certificate Manager
      {
        Effect = "Allow"

        Action = [
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          "acm:ListTagsForCertificate",
          #"acm:DeleteCertificate",
          #"acm:AddTagsToCertificate"
        ]

        Resource = "*"
        #Condition = local.default_read_condition
      },

      # IAM unscoped
      {
        Effect = "Allow"

        Action = [
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:ListPolicyVersions",
        ]

        Resource = "*"
      },

      # IAM scoped
      {
        Effect = "Allow"

        Action = [
          "iam:GetRole",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:ListPolicyVersions",
        ]

        Resource = "*"
        #Condition = local.default_read_condition
      },

      # Read AWS service roles
      {
        Effect = "Allow"

        Action = [
          "iam:GetRole",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies"
        ]

        Resource = local.service_role_arns
      },

      # Secrets Manager
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetResourcePolicy",
        ]

        Resource = "*"
        #Condition = local.default_read_condition
      },

      # Route 53
      # Unfortunately, it isn't possible to scope Route 53 access using tags
      # Nor is it possible to create scoped permissions for zones that don't exist yet
      {
        Effect = "Allow"

        Action = [
          "route53:GetHostedZone",
          "route53:ListHostedZones",
          "route53:ListTagsForResource",
          "route53:ListResourceRecordSets",
          "route53:GetChange"
        ]

        Resource = "*"
      },
    ],
  })
}
