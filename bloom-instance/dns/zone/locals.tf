
locals {
  create_zone = var.zone_id == null
  zone_id     = local.create_zone ? aws_route53_zone.zone["0"].zone_id : var.zone_id
}
