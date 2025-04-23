
module "cloudfront" {
  source = "./cloudfront"


  name_prefix = local.qualified_name_prefix
  name        = "cloudfront"
  domains     = [var.public_portal_domain, "*.${var.public_portal_domain}"]

  alb_map  = module.albs
  cert_map = local.cert_map

  distribution = var.cloudfront
  web_acl_id   = aws_wafv2_web_acl.cloudfront_acl.arn
}
