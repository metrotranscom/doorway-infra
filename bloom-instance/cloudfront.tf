
module "cloudfront" {
  source = "./cloudfront"


  name_prefix = local.qualified_name_prefix
  name        = "cloudfront"
  domains     = [var.public_portal_domain, "*.${var.public_portal_domain}"]

  alb_map  = module.albs
  cert_map = local.cert_map

  distribution = var.cloudfront
}
