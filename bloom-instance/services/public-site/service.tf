
module "service" {
  source = "../base-service"

  name_prefix = var.name_prefix
  #service_name       = var.service_definition.name
  service_definition = local.service_definition

  alb_listener_arn = var.alb_listener_arn
  alb_sg_id        = var.alb_sg_id
  subnet_ids       = var.subnet_ids
  task_role_arn    = aws_iam_role.service.arn

  additional_tags = var.additional_tags
}
