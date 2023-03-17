

# Create zone references in one place, whether we manage them directly or not
module "dns_zones" {
  for_each = { for name, value in var.dns.zones : name => value }
  source   = "./dns/zone"

  name    = each.key
  zone_id = each.value.zone_id

  additional_tags = {
    Test = "yes"
  }
}

# Add zone records specifically defined in zone config
# module "zone_records" {
#   for_each = { for name, value in var.dns.zones : name => value }
#   source   = "./dns/record"

#   zone_id = each.value.zone_id
# }

# Add zone records specifically defined in zone config
# resource "aws_route53_record" "records" {
#   for_each = { for name, value in var.dns.zones : name => value if value.additional_records != null }
#   zone_id  = local.zone_id
#   name     = each.value.name
#   type     = each.value.type
#   ttl      = each.value.ttl
# }
