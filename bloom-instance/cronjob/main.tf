
locals {
  task_name             = var.task.name
  name_prefix           = var.name_prefix
  qualified_name_prefix = "${local.name_prefix}-${local.task_name}"
  subnet_ids            = [for subnet in var.subnet_groups[var.network.subnet_group] : subnet.id]
}

module "task" {
  source = "../ecs/task"

  name_prefix     = local.name_prefix
  task            = var.task
  additional_tags = var.additional_tags
  log_group_name  = var.log_group_name
  task_role_arn   = var.task_role_arn
}

resource "aws_scheduler_schedule" "task" {
  name_prefix = local.qualified_name_prefix

  flexible_time_window {
    mode = "OFF"
  }

  #schedule_expression = "rate(1 hour)"
  schedule_expression = var.schedule.expression
  state               = var.schedule.enabled ? "ENABLED" : "DISABLED"

  target {
    arn      = var.ecs_cluster_arn
    role_arn = aws_iam_role.scheduler_exec.arn

    ecs_parameters {
      task_definition_arn = module.task.arn
      launch_type         = "FARGATE"
      propagate_tags      = "TASK_DEFINITION"
      task_count          = 1

      network_configuration {
        assign_public_ip = var.network.assign_public_ip
        security_groups  = var.network.security_groups
        subnets          = local.subnet_ids
      }
    }
  }
}
