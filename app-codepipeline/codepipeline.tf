# Needed to resolve current AWS Account ID
data "aws_caller_identity" "current" {}
locals {
  ecr_account_id        = var.ecr_account_id == "" ? data.aws_caller_identity.current.account_id : var.ecr_account_id
  ecr_namespace         = var.ecr_namespace == "" ? "${var.name_prefix}-${var.repo.branch}" : var.ecr_namespace
  codebuild_aws_acct_id = data.aws_caller_identity.current.account_id
  common_env_vars = [
    { "name" : "ECR_REGION", "value" : "${var.aws_region}" },
    { "name" : "ECR_ACCOUNT_ID", "value" : "${local.ecr_account_id}" },
    { "name" : "ECR_NAMESPACE", "value" : "${local.ecr_namespace}" }
  ]
  deploy_secrets_env_vars = [
    { "name" : "DB_CREDS_ARN", "value" : var.pgpass_arn_key.arn }
  ]
  build_env_vars = concat(local.common_env_vars, [for n, val in var.build_env_vars : { name = n, value = val }])

  deploy_secrets_env_vars = [
    { "name" : "DB_CREDS_ARN", "value" : var.db_creds_arn }
  ]
  deploy_env_vars = concat(
    local.common_env_vars,
    [for n, val in var.deploy_env_vars : { name = n, value = val }],
  local.deploy_secrets_env_vars)
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
      name             = "BuildBackend"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_backend"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.backend.name
      }
    }
    action {
      name             = "BuildPublic"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_public"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.public.name
      }
    }
    action {
      name             = "BuildPartners"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_partners"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.partners.name
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

    dynamic "environment_variable" {
      for_each = local.deploy_env_vars
      content {
        name  = environment_variable.value["name"]
        value = environment_variable.value["value"]
        type  = can(environment_variable.value["type"]) ? environment_variable.value["type"] : "PLAINTEXT"
      }
    }
  }
  vpc_config {
    vpc_id             = var.codebuild_vpc_id
    subnets            = var.codebuild_vpc_subnets
    security_group_ids = var.codebuild_vpc_sgs
  }
  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "ci/buildspec_deploy.yml"
  }
  depends_on = [aws_iam_role_policy.codebuild_deploy_role_policy_vpc]
}

resource "aws_s3_bucket" "default" {
  bucket_prefix = var.name_prefix
  force_destroy = var.s3_force_delete
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
          aws_codebuild_project.backend.arn,
          aws_codebuild_project.public.arn,
          aws_codebuild_project.partners.arn,
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

resource "aws_iam_role_policy" "codebuild_role_policy_vpc" {
  name = "${var.name_prefix}-codebuild_role_policy_after"
  role = aws_iam_role.codebuild_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeVpcs",
          "ec2:DescribeSecurityGroups"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateNetworkInterfacePermission"
        ],
        "Resource" : "arn:aws:ec2:${var.codebuild_vpc_region}:${local.codebuild_aws_acct_id}:network-interface/*",
        "Condition" : {
          "StringEquals" : {
            "ec2:AuthorizedService" : "codebuild.amazonaws.com"
          },
          "ArnEquals" : {
            "ec2:Subnet" : [for subnet in data.aws_subnet.codebuild_vpc_subnets : subnet.arn]
          }
        }
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
          "${aws_codebuild_project.backend.arn}",
          "${aws_codebuild_project.public.arn}",
          "${aws_codebuild_project.partners.arn}"
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

resource "aws_iam_role_policy" "codebuild_deploy_role_policy_vpc" {
  name = "${var.name_prefix}-codebuild_deploy_role_policy_vpc"
  role = aws_iam_role.codebuild_deploy_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeVpcs",
          "ec2:DescribeSecurityGroups"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateNetworkInterfacePermission"
        ],
        "Resource" : "arn:aws:ec2:${var.codebuild_vpc_region}:${local.codebuild_aws_acct_id}:network-interface/*",
        "Condition" : {
          "StringEquals" : {
            "ec2:AuthorizedService" : "codebuild.amazonaws.com"
          },
          "ArnEquals" : {
            "ec2:Subnet" : [for subnet in data.aws_subnet.codebuild_vpc_subnets : subnet.arn]
          }
        }
      }
    ]
  })
}

data "aws_subnet" "codebuild_vpc_subnets" {
  for_each = toset(var.codebuild_vpc_subnets)
  id       = each.value
}


resource "aws_iam_role_policy" "codebuild_deploy_role_policy" {
  name = "${var.name_prefix}-codebuild_deploy_role_policy"
  role = aws_iam_role.codebuild_deploy_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "ecs:UpdateService",
          "ecs:DescribeServices"
        ]
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
      {
        "Action" : [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          # We're downloading images for re-tagging.
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Effect" : "Allow",
        "Action" : "secretsmanager:GetSecretValue",
        "Resource" : var.db_creds_arn
      }
    ]
  })
}
