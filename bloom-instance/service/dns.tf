
locals {
  alb_domain_map = merge([for alb_name, alb in var.service.albs : merge([
    for listener_name, listener in alb.listeners : {
      for domain in listener.domains : "${local.name}-${alb_name}-${listener_name}-${domain}" => {
        name   = domain
        type   = "A"
        values = [var.alb_map[alb_name].dns_name]
        #ttl    = var.dns.default_ttl

        target = {
          dns_name = var.alb_map[alb_name].dns_name
          zone_id  = var.alb_map[alb_name].zone_id
        }
      }
    }
    ]...)
  ]...)
}

module "alb_aliases" {
  source = "../dns/alias"

  for_each = local.alb_domain_map

  zones  = var.dns.zone_map
  record = each.value
}
