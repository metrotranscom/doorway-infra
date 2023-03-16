
resource "aws_ecr_repository_policy" "repo" {
  repository = aws_ecr_repository.repo.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudBuildPushPull"
        Effect = "Allow"

        Principal = {
          Service = "codebuild.amazonaws.com"
        }

        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
        ]

        # TODO: restrict CloudBuild access more?
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.source_account
          }
        }
      },

      {
        Sid    = "AllowECSPull"
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:ListImages",
        ]

        # TODO: restrict ECR access more?
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.source_account
          }
        }
      },

      {
        Sid    = "AllowUserPushPull"
        Effect = "Allow"

        # This permits all users in the specified account to take the following actions
        # Any users in that account will still need to have IAM permissions granted
        Principal = {
          AWS = "${var.source_account}"
        }

        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchDeleteImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
        ]
      }
    ]
  })
}
