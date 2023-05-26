
resource "aws_iam_role" "pipeline" {
  name = "${var.name_prefix}-pipeline-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Permit CodePipeline to assume this role
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "pipeline" {
  name = "${var.name_prefix}-pipeline"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowUseCodeStarConnection"
        Effect   = "Allow"
        Action   = ["codestar-connections:UseConnection"]
        Resource = local.codestar_connection_arn
      },
      {
        Sid    = "AllowReadWriteArtifactBucket"
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObjectAcl",
          "s3:PutObject",
        ]

        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      },
      {
        Sid    = "AllowUseCodeBuild"
        Effect = "Allow"

        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
        ]

        Resource = ["*"]
      },
    ],
  })
}

resource "aws_iam_policy" "approvals" {
  count = length(local.notification_topic_arns) > 0 ? 1 : 0
  name  = "${var.name_prefix}-approvals"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPublishNotifications"
        Effect = "Allow"

        Action = [
          "sns:Publish"
        ]

        Resource = local.notification_topic_arns
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "pipeline" {
  role       = aws_iam_role.pipeline.name
  policy_arn = aws_iam_policy.pipeline.arn
}

resource "aws_iam_role_policy_attachment" "approvals" {
  count      = length(local.notification_topic_arns) > 0 ? 1 : 0
  role       = aws_iam_role.pipeline.name
  policy_arn = aws_iam_policy.approvals[0].arn
}

resource "aws_iam_policy" "codebuild_artifacts" {
  name = "${var.name_prefix}-codebuild-artifacts"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowReadArtifactBucket"
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning"
        ]

        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      },
    ],
  })
}
