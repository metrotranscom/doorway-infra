
module "dns" {
  source = "./dns"
  dns    = var.dns
}

# Add CNAME records for public site domains to ALB
module "public_site_records" {
  source = "./dns/record"

  for_each = merge([for key, site in var.public_sites : {
    for domain in site.domains : "${key}-${domain}" => {
      name   = domain
      type   = "CNAME"
      values = [module.public_alb.dns_name]
    }
  }]...)

  zones  = module.dns.zone_map
  record = each.value
}
