
resource "aws_iam_role" "service" {
  name = "${local.resource_namespace}-ecs"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Permit ECS to assume this role
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "service_s3_access" {
  name = "${local.resource_namespace}-s3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "ListObjects"
        Action = [
          "s3:ListBucket",
        ]
        Effect   = "Allow"
        Resource = local.s3_access_policy_resource,
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "service_s3_access" {
  role       = aws_iam_role.service.name
  policy_arn = aws_iam_policy.service_s3_access.arn
}
