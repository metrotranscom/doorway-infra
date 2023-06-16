
resource "aws_iam_policy" "modify" {
  name = "${local.qualified_name}-modify"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # S3 (does not support ABAC)
      {
        "Action" : [
          "s3:DeleteBucket",
          "s3:PutBucketTagging",
          "s3:PutBucketPolicy"
        ],
        "Effect" : "Allow",
        "Resource" : "${local.s3_bucket_arn}*"
      },

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

      # EventBridge Scheduler
      {
        Effect = "Allow"

        Action = [
          "scheduler:TagResource",
          "scheduler:UntagResource",
          "scheduler:ListTagsForResource"
        ]

        Resource  = "*"
        Condition = local.default_modify_condition
      },

      # ECS
      {
        Effect = "Allow"

        Action = [
          "ecs:DeleteCluster",
          "ecs:DeleteService",
          "ecs:DeregisterTaskDefinition",
          "ecs:UpdateCluster",
          "ecs:UpdateService",
          "ecs:UpdateClusterSettings",
          "ecs:UntagResource",
          "ecs:TagResource"
        ]

        Resource  = "*"
        Condition = local.default_modify_condition
      },

      # Elastic Load Balancing
      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:RemoveListenerCertificates",
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:SetSecurityGroups",
          # Might create a problem if the resource doesn't have condition tags to being with?
          "elasticloadbalancing:AddTags",
          # Originally with no condition
          "elasticloadbalancing:RemoveTags"
        ]

        Resource  = "*"
        Condition = local.default_modify_condition
      },

      # Amazon Certificate Manager
      {
        Effect = "Allow"

        Action = [
          "acm:DeleteCertificate",
          "acm:UpdateCertificateOptions",
          "acm:RemoveTagsFromCertificate",
          "acm:AddTagsToCertificate"
        ]

        Resource  = "*"
        Condition = local.default_modify_condition
      },

      # IAM
      {
        Effect = "Allow"

        Action = [
          "iam:UpdateRole",
          "iam:AttachRolePolicy",
          "iam:CreatePolicyVersion",
          "iam:DetachRolePolicy",
          "iam:DeleteRole",
          "iam:DeletePolicy",
          "iam:DeletePolicyVersion",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:TagPolicy",
          "iam:UntagPolicy"
        ]

        Resource  = "*"
        Condition = local.default_modify_condition
      },

      # Secrets Manager
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:UpdateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:TagResource",
          "secretsmanager:PutResourcePolicy",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UntagResource"
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
