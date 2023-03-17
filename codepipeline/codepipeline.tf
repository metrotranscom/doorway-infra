resource "aws_codepipeline" "default" {
  name     = "${var.name_prefix}-codepipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.default.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      name     = "Source"
      owner    = "AWS"
      provider = "CodeStarSourceConnection"
      version  = "1"

      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.default.arn
        FullRepositoryId = var.repo_name
        BranchName       = var.repo_branch_name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.default.name
      }
    }
  }
}

resource "aws_codebuild_project" "default" {
  name         = "${var.name_prefix}-codebuild"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  source {
    type = "CODEPIPELINE"
  }
}

resource "aws_s3_bucket" "default" {
  bucket_prefix = var.name_prefix
}

# NOTE: Auth with the GitHub must be completed in the AWS Console.
resource "aws_codestarconnections_connection" "default" {
  name          = "${var.name_prefix}-connection"
  provider_type = "GitHub"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.name_prefix}-codepipeline_role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codepipeline.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_role_policy" {
  name = "${var.name_prefix}-codepipeline_role_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        "Resource" : [
          "${aws_s3_bucket.default.arn}",
          "${aws_s3_bucket.default.arn}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "codestar-connections:UseConnection"
        ],
        "Resource" : [
          "${aws_codestarconnections_connection.default.arn}"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ],
        "Resource" : [
          "${aws_codebuild_project.default.arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "codebuild_role" {
  name = "${var.name_prefix}-codebuild_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codebuild.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_role_policy" {
  name = "${var.name_prefix}-codebuild_role_policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:logs:*:*:log-group:/aws/codebuild/*"
        ],
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
        ]
      },
      {
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:logs:*:*:log-group:/aws/codebuild/*:log-stream:*"
        ],
        "Action" : [
          "logs:PutLogEvents"
        ]
      },
      {
        "Effect" : "Allow",
        "Resource" : [
          "${aws_s3_bucket.default.arn}",
          "${aws_s3_bucket.default.arn}/*"
        ],
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ],
        "Resource" : [
          "${aws_codebuild_project.default.arn}"
        ]
      }
    ]
  })
}
