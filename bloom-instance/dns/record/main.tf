
locals {
  zone_id     = module.resolver.match
  match_found = true
}

module "resolver" {
  source = "../zone-resolver"

  zones       = var.zones
  record_name = var.record.name
}

resource "aws_route53_record" "record" {
  count = local.zone_id != null ? 1 : 0

  zone_id = local.zone_id
  name    = var.record.name
  type    = var.record.type
  ttl     = var.record.ttl
}
