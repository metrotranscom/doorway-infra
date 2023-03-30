
resource "aws_ecs_task_definition" "task" {
  # This must be unique
  # Only alphanumeric characters, hyphens, and underscores
  family                   = local.default_name
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = var.task_role_arn
  execution_role_arn       = aws_iam_role.task_exec.arn

  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu    = local.cpu
  memory = local.ram

  network_mode = "awsvpc"

  container_definitions = jsonencode([
    {
      name      = local.name
      image     = local.image
      cpu       = local.cpu
      memory    = local.ram
      essential = true
      portMappings = [
        {
          # Host port and container port must be the same with the awsvpc network type
          containerPort = local.port
          hostPort      = local.port
        }
      ]
      environment = [for n, val in local.env_vars : { name = n, value = val }]
    }
  ])

  tags = var.additional_tags
}
