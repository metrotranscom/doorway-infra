
# resource "aws_ecs_cluster" "service" {
#   name = local.default_name
#   tags = var.additional_tags
# }

resource "aws_ecs_service" "service" {
  # Only alphanumeric characters, hyphens, and underscores
  name = local.default_name
  #cluster         = aws_ecs_cluster.service.id
  cluster         = var.service.cluster_name
  task_definition = local.task_id

  desired_count = local.desired_count
  launch_type   = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.service.arn
    container_name   = local.name
    container_port   = local.port
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.service.id]
    subnets          = local.subnet_ids
  }

  # Application Auto Scaling will be modifying the number of running containers,
  # so don't trigger a change if it's different.
  lifecycle {
    ignore_changes = [desired_count]
  }

  deployment_controller {
    type = "ECS"
  }

  tags = var.additional_tags
}
