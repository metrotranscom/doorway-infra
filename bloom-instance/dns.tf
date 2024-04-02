

# module "cloudfront_aliases" {
#   source = "./dns/alias"

#   for_each = local.cloudfront_domains

#   zones       = module.dns.zone_map
#   record_name = each.value
#   zone_id     = module.albs["public"].zone_id
#   target_name = module.albs["public"].dns_name
# }

