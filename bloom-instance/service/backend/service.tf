
module "service" {
  source = "../"

  alb_map    = var.alb_map
  subnet_map = var.subnet_map

  name_prefix = var.name_prefix
  name        = local.name
  port        = local.port
  task        = local.task
  service     = local.service

  task_role_arn  = aws_iam_role.service.arn
  log_group_name = var.log_group_name
  cluster_name   = var.cluster_name

  additional_tags = var.additional_tags
}
