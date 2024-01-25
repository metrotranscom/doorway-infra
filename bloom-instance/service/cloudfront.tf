
module "cloudfront" {
  source = "../cloudfront"
  count  = var.cloudfront != null ? 1 : 0

  name_prefix = local.qualified_name
  name        = local.name

  alb_map  = var.alb_map
  cert_map = var.cert_map

  distribution = var.cloudfront
  providers = {
    "aws" = aws.use1
  }
}
