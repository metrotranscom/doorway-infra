
module "cloudfront" {
  source = "./cloudfront"


  name_prefix = local.qualified_name_prefix
  name        = "cloudfront"
  domains     = local.cloudfront_domains

  alb_map  = module.albs
  cert_map = local.cert_map

  distribution = var.cloudfront
}
