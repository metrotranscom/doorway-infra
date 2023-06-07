
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
        Sid    = "AllowPushToRepo"
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],

        Resource = local.arn
      },
    ],
  })
}
