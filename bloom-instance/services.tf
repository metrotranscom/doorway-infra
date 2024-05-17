
# There may be multiple public sites
module "public_sites" {
  for_each = { for idx, srv in var.public_sites : idx => srv }
  source   = "./service/public-site"

  name_prefix        = local.qualified_name_prefix
  service_definition = each.value
  log_group_name     = local.task_log_group_name
  #cloudfront         = try(each.value.cloudfront, null)

  alb_map      = module.albs
  subnet_map   = module.network.subnets
  cluster_name = aws_ecs_cluster.default.name
  dns          = module.dns
  cert_map     = local.cert_map


  # Just a placeholder for now
  backend_api_base = "https://${var.backend_api_domain}"
  additional_tags = {
    ServiceType = "public-site"
    ServiceName = each.value.name
  }
  vpc_id             = module.network.vpc.id
  alb_arn            = module.albs["public"].arn
  https_listener_arn = module.albs["public"].https_listener_arn
  cert_arn           = module.certs["housingbayarea"].arn
  site_urls          = [var.public_portal_domain]
  security_group_id  = aws_security_group.ecs_sg.id
}

# So far, there only seems to be a need for a single partner site
module "partner_site" {
  source = "./service/partner-site"

  name_prefix        = local.qualified_name_prefix
  service_definition = var.partner_site
  log_group_name     = local.task_log_group_name
  #cloudfront         = try(var.partner_site.cloudfront, null)

  alb_map      = module.albs
  subnet_map   = module.network.subnets
  cluster_name = aws_ecs_cluster.default.name
  dns          = module.dns
  cert_map     = local.cert_map

  # Just a placeholder for now
  backend_api_base = "https://${var.backend_api_domain}"

  additional_tags = {
    ServiceType = "partner-site"
    ServiceName = var.partner_site.name
  }
  vpc_id            = module.network.vpc.id
  alb_arn           = module.albs["public"].arn
  cert_arn          = module.certs["housingbayarea"].arn
  site_urls         = [var.partners_portal_domain]
  security_group_id = aws_security_group.ecs_sg.id
}

module "backend_api" {
  source  = "./service/backend"
  api_url = var.backend_api_domain

  name_prefix        = local.qualified_name_prefix
  service_definition = var.backend_api
  log_group_name     = local.task_log_group_name

  alb_map      = module.albs
  subnet_map   = module.network.subnets
  dns          = module.dns
  db           = module.db
  cluster_name = aws_ecs_cluster.default.name

  public_upload_bucket = aws_s3_bucket.public_uploads.bucket

  migration = var.backend_api.migration

  partners_portal_url = var.backend_api.partners_portal_url

  internal_url_path = var.backend_api.internal_url_path

  additional_tags = {
    ServiceType = "backend-api"
    ServiceName = var.backend_api.name
  }
  vpc_id            = module.network.vpc.id
  alb_arn           = module.albs["public"].arn
  cert_arn          = module.certs["housingbayarea"].arn
  security_group_id = aws_security_group.ecs_sg.id
}
