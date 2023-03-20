
locals {
  create_zone = var.zone_id == null
  zone_id     = local.create_zone ? aws_route53_zone.zone["0"].zone_id : var.zone_id
}

resource "aws_route53_zone" "zone" {
  count = local.create_zone ? 1 : 0
  name  = var.name

  tags = var.additional_tags
}
