
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

resource "aws_iam_role_policy_attachment" "report" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.reporting.arn
}

# Add the ability to read necessary secrets
resource "aws_iam_policy" "secrets" {
  count = length(var.secret_arns) > 0 ? 1 : 0
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

        Resource = var.secret_arns
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "secrets" {
  count      = length(var.secret_arns) > 0 ? 1 : 0
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.secrets[0].arn
}
