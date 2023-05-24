
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
