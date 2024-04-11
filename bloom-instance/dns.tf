
data "aws_route53_zone" "zone" {
  name = "housingbayarea.mtc.ca.gov."

}
# terraform can't seem to find private zones w/ zone name unfortunately
data "aws_route53_zone" "zone_int" {
  zone_id = "Z04687811M3N0Y9KL9A5F"

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
  zone_id = data.aws_route53_zone.zone_int.zone_id
  name    = var.backend_api_domain
  type    = "A"
  alias {
    name                   = module.albs["api"].dns_name
    zone_id                = module.albs["api"].zone_id
    evaluate_target_health = false
  }

}

