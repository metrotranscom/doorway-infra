
resource "aws_ecs_cluster" "service" {
  name = "${var.name_prefix}-${var.service_name}"
}

resource "aws_ecs_task_definition" "task" {
  # This must be unique
  # Only alphanumeric characters, hyphens, and underscores
  family                   = "${var.name_prefix}-${var.service_name}"
  requires_compatibilities = ["FARGATE"]

  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu    = var.cpu
  memory = var.ram

  network_mode = "awsvpc"

  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = var.image
      cpu       = var.cpu
      memory    = var.ram
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.host_port
        }
      ]
      environment = [for n, val in var.env_vars : { name = n, value = val }]
    }
  ])

}

resource "aws_ecs_service" "service" {
  # Only alphanumeric characters, hyphens, and underscores
  name            = "${var.name_prefix}-${var.service_name}"
  cluster         = aws_ecs_cluster.service.id
  task_definition = aws_ecs_task_definition.task.id

  desired_count = 1
  launch_type   = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.service.arn
    container_name   = var.service_name
    container_port   = var.container_port
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
}

