

# module "cloudfront_aliases" {
#   source = "./dns/alias"

#   for_each = local.cloudfront_domains

#   zones       = module.dns.zone_map
#   record_name = each.value
#   zone_id     = module.albs["public"].zone_id
#   target_name = module.albs["public"].dns_name
# }

data "aws_route53_zone" "zone" {
  name = "housingbayarea.mtc.ca.gov."

}
resource "aws_route53_record" "public" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.public_portal_domain
  type    = "A"
  records = [module.cloudfront.dns_name]

}
resource "aws_route53_record" "partners" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.partners_portal_domain
  type    = "A"
  records = [module.cloudfront.dns_name]

}

