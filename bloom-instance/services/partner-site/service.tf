
# module "service" {
#   source = "../base-service"

#   name_prefix = var.name_prefix
#   #service_name       = var.service_definition.name
#   service_definition = local.service_definition

#   alb_listener_arn = var.alb_listener_arn
#   alb_sg_id        = var.alb_sg_id
#   subnet_ids       = var.subnet_ids
#   task_role_arn    = aws_iam_role.service.arn

#   additional_tags = var.additional_tags
# }

module "service" {
  source = "../"

  alb_map    = var.alb_map
  subnet_map = var.subnet_map

  name_prefix = var.name_prefix
  name        = local.name
  port        = local.port
  task        = local.task
  service     = local.service

  task_role_arn = aws_iam_role.service.arn

  additional_tags = var.additional_tags
}
