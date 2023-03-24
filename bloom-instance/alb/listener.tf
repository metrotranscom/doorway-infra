
module "listeners" {
  source = "./listener"

  for_each = { for k, v in var.listeners : k => v }

  subnets           = var.subnets
  alb_arn           = aws_lb.alb.arn
  security_group_id = aws_security_group.alb.id

  #settings = each.value

  port            = each.value.port
  tls             = each.value.tls
  allowed_ips     = each.value.allowed_ips
  allowed_subnets = each.value.allowed_subnets
  #use_tls      = each.value.use_tls
  #force_tls    = each.value.force_tls
  #default_cert = each.value.default_cert

  additional_tags = var.additional_tags
}
