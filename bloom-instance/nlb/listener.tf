
module "listeners" {
  source = "./listener"

  for_each = { for k, v in var.listeners : k => v }

  # Passthru
  subnets = var.subnets


  # Module resources
  nlb_arn           = aws_lb.nlb.arn
  security_group_id = aws_security_group.nlb.id

  # From config

  allowed_ips = each.value.allowed_ips
  # allowed_subnets = each.value.allowed_subnets


  additional_tags  = var.additional_tags
  certificate_arn  = var.certificate_arn
  allowed_subnets  = each.value.allowed_subnets
  target_group_arn = var.target_group_arn
}
