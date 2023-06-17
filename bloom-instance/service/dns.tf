
locals {

  cloudfront_outputs = length(module.cloudfront) > 0 ? module.cloudfront[0] : null

  cloudfront_domain_map = local.cloudfront_outputs == null ? {} : {
    for domain in local.cloudfront_outputs.domains : "${local.name}-cloudfront-${domain}" => {
      name = domain
      type = "A"

      target = {
        dns_name = local.cloudfront_outputs.dns_name
        zone_id  = local.cloudfront_outputs.hosted_zone_id
      }
    }
  }

  cloudfront_domains = local.cloudfront_outputs == null ? [] : local.cloudfront_outputs.domains

  # Only add ALB records for domains that aren't used by CloudFront
  alb_domain_map = merge([for alb_name, alb in var.service.albs : merge([
    for listener_name, listener in alb.listeners : {
      for domain in listener.domains : "${local.name}-${alb_name}-${listener_name}-${domain}" => {
        name = domain
        type = "A"
        #values = [var.alb_map[alb_name].dns_name]

        target = {
          dns_name = var.alb_map[alb_name].dns_name
          zone_id  = var.alb_map[alb_name].zone_id
        }
        # Don't create a DNS record for the ALB if CloudFront needs it
      } if !contains(local.cloudfront_domains, domain)
    }
    ]...)
  ]...)
}

module "cloudfront_aliases" {
  source = "../dns/alias"

  for_each = local.cloudfront_domain_map

  zones  = var.dns.zone_map
  record = each.value
}

module "alb_aliases" {
  source = "../dns/alias"

  for_each = local.alb_domain_map

  zones  = var.dns.zone_map
  record = each.value
}
