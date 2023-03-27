
module "listeners" {
  source = "./listener"

  for_each = { for k, v in var.listeners : k => v }

  # Passthru
  subnets  = var.subnets
  cert_map = var.cert_map

  # Module resources
  alb_arn           = aws_lb.alb.arn
  security_group_id = aws_security_group.alb.id

  # From config
  port            = each.value.port
  tls             = each.value.tls
  allowed_ips     = each.value.allowed_ips
  allowed_subnets = each.value.allowed_subnets

  additional_tags = var.additional_tags
}
