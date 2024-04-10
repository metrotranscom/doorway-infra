
data "aws_route53_zone" "zone" {
  name = "housingbayarea.mtc.ca.gov."

}
resource "aws_route53_record" "public" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.public_portal_domain
  type    = "A"
  alias {
    name                   = module.cloudfront.dns_name
    zone_id                = module.cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}
resource "aws_route53_record" "partners" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.partners_portal_domain
  type    = "A"
  alias {
    name                   = module.cloudfront.dns_name
    zone_id                = module.cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}
resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.backend_api_domain
  type    = "A"
  alias {
    name                   = module.albs["public"].dns_name
    zone_id                = module.albs["public"].zone_id
    evaluate_target_health = false
  }

}

