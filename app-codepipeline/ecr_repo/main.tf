
locals {
  qualified_name = "${var.name_prefix}-${var.name}"

  full_repo_name = "${var.namespace}/${var.name}"

  arn = "arn:aws:ecr:${var.region}:${var.account}:repository/${local.full_repo_name}"
  url = "${var.account}.dkr.ecr.${var.region}.amazonaws.com/${local.full_repo_name}"
}

resource "aws_iam_policy" "pull" {
  name = "${local.qualified_name}-pull"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # We need the ability to authenticate to ECR regardless of other permissions
        Sid    = "AllowGetAuthorization"
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken",
        ],

        Resource = "*"
      },
      {
        Sid    = "AllowPullFromRepo"
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:ListImages",
        ],

        Resource = local.arn
      },
    ],
  })
}

resource "aws_iam_policy" "push" {
  name = "${local.qualified_name}-push"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # We need the ability to authenticate to ECR regardless of other permissions
        Sid    = "AllowGetAuthorization"
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken",
        ],

        Resource = "*"
      },
      {
        Sid    = "AllowPushToRepo"
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],

        Resource = local.arn
      },
    ],
  })
}

resource "aws_iam_policy" "retag" {
  name = "${local.qualified_name}-retag"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # We need the ability to authenticate to ECR regardless of other permissions
        Sid    = "AllowGetAuthorization"
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken",
        ],

        Resource = "*"
      },
      {
        Sid    = "AllowPushToRepo"
        Effect = "Allow"

        Action = [
          "ecr:BatchGetImage",
          "ecr:PutImage"
        ],

        Resource = local.arn
      },
    ],
  })
}
