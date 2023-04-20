
module "dns" {
  source = "./dns"
  dns    = var.dns
}

# Add CNAME records for public site domains pointing to ALB
module "public_site_records" {
  source = "./dns/record"

  for_each = merge([for site_name, site in var.public_sites : merge([
    for alb_name, alb in site.service.albs : merge([
      for listener_name, listener in alb.listeners : {
        for domain in listener.domains : "public-${site_name}-${alb_name}-${listener_name}-${domain}" => {
          name   = domain
          type   = "CNAME"
          values = [module.albs[alb_name].dns_name]
          ttl    = module.dns.default_ttl
        }
      }
    ]...)
  ]...)]...)

  zones  = module.dns.zone_map
  record = each.value
}

# Add CNAME records for partner site domains pointing to ALB
module "partner_site_records" {
  source = "./dns/record"

  for_each = merge([for alb_name, alb in var.partner_site.service.albs : merge([
    for listener_name, listener in alb.listeners : {
      for domain in listener.domains : "partner-${alb_name}-${listener_name}-${domain}" => {
        name   = domain
        type   = "CNAME"
        values = [module.albs[alb_name].dns_name]
        ttl    = module.dns.default_ttl
      }
    }
    ]...)
  ]...)

  zones  = module.dns.zone_map
  record = each.value
}
