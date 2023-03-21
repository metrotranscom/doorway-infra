
resource "aws_ecs_cluster" "service" {
  name = local.default_name
  tags = var.additional_tags
}

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

resource "aws_ecs_service" "service" {
  # Only alphanumeric characters, hyphens, and underscores
  name            = local.default_name
  cluster         = aws_ecs_cluster.service.id
  task_definition = aws_ecs_task_definition.task.id

  desired_count = 1
  launch_type   = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.service.arn
    container_name   = local.name
    container_port   = local.port
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.service.id]
    subnets          = var.subnet_ids
  }

  # Application Auto Scaling will be modifying the number of running containers,
  # so don't trigger a change if it's different.
  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = var.additional_tags
}
