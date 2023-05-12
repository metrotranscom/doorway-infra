
module "task" {
  source = "../ecs/task"

  name_prefix    = var.name_prefix
  task_role_arn  = var.task_role_arn
  log_group_name = var.log_group_name

  task = merge(
    var.task,
    {
      name = var.name
      port = var.port
    }
  )

  additional_tags = var.additional_tags
}

module "service" {
  source = "../ecs/service"

  name_prefix = var.name_prefix
  alb_map     = var.alb_map
  subnet_map  = var.subnet_map
  task_arn    = module.task.arn

  service = merge(
    var.service,
    {
      name = var.name
      port = var.port
    }
  )

  additional_tags = var.additional_tags
}
