
# Attach all supplied policies
resource "aws_iam_role_policy_attachment" "supplied" {
  for_each   = var.policy_arns
  role       = aws_iam_role.codebuild.name
  policy_arn = each.value
}

# Add permission to write logs
resource "aws_iam_policy" "write_logs" {
  name = "${local.qualified_name}-logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowWriteLogs"
        Effect = "Allow"

        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
        ]

        Resource = [
          "arn:aws:logs:*:*:log-group:/aws/codebuild/${local.qualified_name}:log-stream:*"
        ]
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "write_logs" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.write_logs.arn
}

# Add the ability to write reporting data
resource "aws_iam_policy" "reporting" {
  name = "${local.qualified_name}-reporting"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPutReportData"
        Effect = "Allow"

        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ]

        Resource = [
          aws_codebuild_project.project.arn
        ]
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "reporting" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.reporting.arn
}

# Add the ability to read necessary secrets
resource "aws_iam_policy" "secrets" {
  count = local.has_secrets ? 1 : 0
  name  = "${local.qualified_name}-secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowReadSecret"
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = local.secret_arn_values
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "secrets" {
  count      = local.has_secrets ? 1 : 0
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.secrets[0].arn
}

resource "aws_iam_policy" "network" {
  count = local.use_network ? 1 : 0
  name  = "${local.qualified_name}-network"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Unscoped permissions
      {
        Sid    = "AllowDescribeNetworkResources"
        Effect = "Allow"

        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSubnets",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeVpcs",
          "ec2:DescribeSecurityGroups",

          # These have to be granted broadly in order to work, apparently
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
        ],

        Resource = "*"
      },
      {
        Sid    = "AllowDelegateCreateNetworkInterface"
        Effect = "Allow"

        Action = [
          "ec2:CreateNetworkInterfacePermission"
        ],

        Resource = "arn:aws:ec2:*:*:network-interface/*",

        Condition = {
          StringEquals = {
            "ec2:AuthorizedService" : "codebuild.amazonaws.com"
          },
          ArnEquals = {
            "ec2:Subnet" : local.subnet_arns
          }
        }
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "network" {
  count      = local.use_network ? 1 : 0
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.network[0].arn
}
