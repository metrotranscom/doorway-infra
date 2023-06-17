
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
  backend_api_base = module.backend_api.internal_url

  additional_tags = {
    ServiceType = "public-site"
    ServiceName = each.value.name
  }
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
  backend_api_base = module.backend_api.internal_url

  additional_tags = {
    ServiceType = "partner-site"
    ServiceName = var.partner_site.name
  }
}

module "backend_api" {
  source = "./service/backend"

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
}
