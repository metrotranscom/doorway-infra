
locals {
  default_ttl = var.dns.default_ttl
  zone_map    = { for k, v in var.dns.zones : k => v.id }
}

# Add zone records specifically defined in zone config
resource "aws_route53_record" "records" {
  # Combine all additional records from all zones into a single map
  for_each = merge([for zone_name, zone in var.dns.zones : {
    for record in zone.additional_records : "${zone_name}-${record.name}-${record.type}" => merge(record, {
      # Add the zone id to the value
      zone_id = zone.id
    }) if zone.additional_records != null
  }]...)

  zone_id = each.value.zone_id
  name    = each.value.name
  type    = each.value.type
  records = each.value.values
  ttl     = each.value.ttl != null ? each.value.ttl : local.default_ttl
}

/*
zone if zone.additional_records != null 
for_each = merge([for key, site in var.public_sites : {
    for domain in site.domains : "${key}-${domain}" => {
      name   = domain
      type   = "CNAME"
      values = [module.public_alb.dns_name]
    }
  }]...)
  */
