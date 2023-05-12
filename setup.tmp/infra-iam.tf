
/*
resource "aws_iam_policy" "bloom_infra_policy" {
  name = "BloomInfraDeploymentAccess"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "EnableVPCManagement"
        Action = [
          "ec2:AssociateRouteTable",
          "ec2:AssociateSubnetCidrBlock",
          "ec2:AssociateVpcCidrBlock",
          "ec2:AttachInternetGateway",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupIngress",
        ]
        Effect   = "Allow"
        Resource = "*",
        Condition = {
          StringEquals = {
            "ec2:ResourceTag/Project" : var.project_name
          }
        }
      },
      {
        Sid = "EnableVPCManagement"
        Action = [
          "ec2:CreateInternetGateway",
          #"ec2:CreateNatGateway",
        ]
        Effect    = "Allow"
        Resource  = "*",
        Condition = local.request_tag_condition
      },
      {
        Sid = "EnableRouteCreation"
        Action = [
          "ec2:CreateRoute",
        ]
        Effect   = "Allow"
        Resource = local.arn.route_table,
        Condition = {
          StringEquals = {
            "aws:RequestTag/Project" : var.project_name
          }
        }
      },
      {
        Sid = "EnableVPCResourceCreation"
        Action = [
          "ec2:CreateRouteTable",
          "ec2:CreateSecurityGroup",
          "ec2:CreateSubnet"
        ]
        Effect    = "Allow"
        Resource  = local.arn.vpc,
        Condition = local.resource_tag_condition
      },
      {
        Sid = "EnableVPCCreation"
        Action = [
          "ec2:CreateVpc",
        ]
        Effect    = "Allow"
        Resource  = "*",
        Condition = local.request_tag_condition
      },
      {
        Sid = "EnableVPCTagCreation"
        Action = [
          "ec2:CreateTags",
        ]
        Effect   = "Allow"
        Resource = local.arn.vpc,
        Condition = {
          "StringEquals" : {
            "aws:RequestTag/Project" = var.project_name,
            "ec2:CreateAction"       = "CreateVpc"
          },
        }
      },
      {
        Sid = "EnableRouteTableTagCreation"
        Action = [
          "ec2:CreateTags",
        ]
        Effect   = "Allow"
        Resource = local.arn.route_table,
        Condition = {
          "StringEquals" : {
            "aws:RequestTag/Project" = var.project_name,
            "ec2:CreateAction"       = "CreateRouteTable"
          },
        }
      },
      {
        Sid = "EnableRouteTagCreation"
        Action = [
          "ec2:CreateTags",
        ]
        Effect   = "Allow"
        Resource = local.arn.route_table,
        Condition = {
          "StringEquals" : {
            "aws:RequestTag/Project" = var.project_name,
            "ec2:CreateAction"       = "CreateRoute"
          },
        }
      },
      {
        Sid = "EnableS3BucketManagement"
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:GetBucket*",
          "s3:PutBucketTagging"
        ]
        Effect   = "Allow"
        Resource = local.arn.s3_bucket,
      },
      {
        Sid = "EnableRDSDatabaseManagement"
        Action = [
          "rds:*"
        ]
        Effect   = "Allow"
        Resource = "*",
        Condition = {
          StringEquals = {
            "rds:db-tag/Project" : var.project_name
          }
        }
      },
      {
        Action = [
          "ecr:*",
          "application-autoscaling:*"
        ]
        Effect   = "Allow"
        Resource = "*",
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Project" : var.project_name
          }
        }
      },
    ]
  })
}

resource "aws_iam_role" "bloom_infra_provisioner" {
  name = "BloomInfraProvisioner"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Permit CodeBuild to assume this role
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bloom_infra" {
  role       = aws_iam_role.bloom_infra_provisioner.name
  policy_arn = aws_iam_policy.bloom_infra_policy.arn
}

*/
