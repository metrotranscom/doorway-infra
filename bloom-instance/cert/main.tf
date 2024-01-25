
locals {
  # DNS records required for cert validation
  validation_records = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      values = [dvo.resource_record_value]
      type   = dvo.resource_record_type
      ttl    = 60
    }
  }

  # Zones that we know about and can resolve to a specific ID
  matched_zones = { for domain, zone in module.zones : domain => zone.id if zone.id != null }

  # Domain names that cannot be resolved to a known zone
  unmatched_zones = [for domain, zone in module.zones : domain if zone.id == null]

  # The records we're going to create automatically
  /*
  matched_records = { for domain, zone_id in local.matched_zones : domain => merge(
    {
      zone_id = zone_id
    },
    local.validation_records[domain]
    )
  }
  */

  # The records that do not match a known zone and must be created manually elsewhere
  unmatched_records = { for domain in local.unmatched_zones : domain => local.validation_records[domain] }

  auto_validate = var.cert.auto_validate
}


resource "aws_acm_certificate" "cert" {
 
  domain_name               = var.cert.domain
  validation_method         = "DNS"
  subject_alternative_names = var.cert.alt_names
}

module "zones" {
  source = "../dns/zone-resolver"

  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name =>
    # The record names usually begin with a "_" and end in a ".", breaking zone lookups
    # Remove if found
    trimsuffix(trimprefix(dvo.resource_record_name, "_"), ".")
  }

  zone_map = var.zones
  dns_name = each.value
}

resource "aws_route53_record" "cert" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      values  = [dvo.resource_record_value]
      type    = dvo.resource_record_type
      ttl     = 60
      zone_id = module.zones[dvo.domain_name].id
    } if local.auto_validate
  }

  allow_overwrite = true
  name            = each.value.name
  records         = each.value.values
  ttl             = each.value.ttl
  type            = each.value.type
  zone_id         = each.value.zone_id

  depends_on = [
    aws_acm_certificate.cert,
    module.zones
  ]
}

resource "aws_acm_certificate_validation" "cert" {
  
  count                   = local.auto_validate ? 1 : 0
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert : record.fqdn]
}

