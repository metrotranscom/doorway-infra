
module "listeners" {
  source = "./listener"

  for_each    = { for k, v in var.listeners : k => v }
  name_prefix = var.name_prefix
  # Passthru
  subnets = var.subnets


  # Module resources
  nlb_arn           = aws_lb.nlb.arn
  security_group_id = aws_security_group.nlb.id

  # From config

  allowed_ips = each.value.allowed_ips
  # allowed_subnets = each.value.allowed_subnets


  additional_tags = var.additional_tags
  certificate_arn = var.certificate_arn
  allowed_subnets = each.value.allowed_subnets
  alb_arn         = var.alb_arn
  vpc_id          = var.vpc_id
}
