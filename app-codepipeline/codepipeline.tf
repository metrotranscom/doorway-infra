# Needed to resolve current AWS Account ID
data "aws_caller_identity" "current" {}
locals {
  ecr_account_id = var.ecr_account_id == "" ? data.aws_caller_identity.current.account_id : var.ecr_account_id
  ecr_namespace  = var.ecr_namespace == "" ? "${var.name_prefix}-${var.repo.branch}" : var.ecr_namespace
  # build_env_vars = list(object({"name"=string, "value"=string}))
  build_env_vars = [
    { "name" : "ECR_REGION", "value" : "${var.aws_region}" },
    { "name" : "ECR_ACCOUNT_ID", "value" : "${local.ecr_account_id}" },
    { "name" : "ECR_NAMESPACE", "value" : "${local.ecr_namespace}" },
    { "name" : "CLOUDINARY_NAME", "value" : "${var.cloudinary_name}" },
    { "name" : "FILE_SERVICE", "value" : "${var.file_service}" }
  ]
}


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
        ConnectionArn    = data.aws_codestarconnections_connection.default.arn
        FullRepositoryId = var.repo.name
        BranchName       = var.repo.branch
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

  stage {
    name = "BuildDeploy"

    action {
      name             = "BuildDeploy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = []
      version          = "1"

      configuration = {
        ProjectName   = aws_codebuild_project.deploy_ecs.name
        PrimarySource = "source_output"
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
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    dynamic "environment_variable" {
      for_each = local.build_env_vars
      content {
        name  = environment_variable.value["name"]
        value = environment_variable.value["value"]
      }
    }
  }
  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "ci/buildspec_${var.repo.branch}.yml"
  }

  build_timeout = "120"
}

resource "aws_codebuild_project" "deploy_ecs" {
  name         = "${var.name_prefix}-codebuild-deploy"
  service_role = aws_iam_role.codebuild_deploy_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    environment_variable {
      name  = "SDLC_STAGE"
      value = var.sdlc_stage
    }

  }


  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "ci/buildspec_deploy_${var.repo.branch}.yml"
  }
}

resource "aws_s3_bucket" "default" {
  bucket_prefix = var.name_prefix
}


# NOTE: Auth with the GitHub must be completed in the AWS Console.
data "aws_codestarconnections_connection" "default" {
  name = var.gh_codestar_conn_name
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
          "${data.aws_codestarconnections_connection.default.arn}"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ],
        "Resource" : [
          aws_codebuild_project.default.arn,
          aws_codebuild_project.deploy_ecs.arn
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
      },
      {
        "Action" : [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      }
    ]
  })
}


## We're punting on using CodeDeploy to deploy to ECS. For now
## we have a CodeBuild stage that calls `aws ecs update-service` directly.
resource "aws_iam_role" "codebuild_deploy_role" {
  name = "${var.name_prefix}-codebuild_deploy_role"
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

resource "aws_iam_role_policy" "codebuild_deploy_role_policy" {
  name = "${var.name_prefix}-codebuild_deploy_role_policy"
  role = aws_iam_role.codebuild_deploy_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "ecs:UpdateService",
        "Effect" : "Allow",
        "Resource" : "*"
      },
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
          "${aws_codebuild_project.deploy_ecs.arn}"
        ]
      },

    ]
  })
}
