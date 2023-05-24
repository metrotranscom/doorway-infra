
# There may be multiple public sites
module "public_sites" {
  for_each = { for idx, srv in var.public_sites : idx => srv }
  source   = "./service/public-site"

  name_prefix        = local.default_name
  service_definition = each.value
  log_group_name     = local.task_log_group_name

  alb_map    = module.albs
  subnet_map = module.network.subnets

  # Just a placeholder for now
  backend_api_base = "http://localhost:3100"

  additional_tags = {
    ServiceType = "public-site"
    ServiceName = each.value.name
  }
}

# So far, there only seems to be a need for a single partner site
module "partner_site" {
  source = "./service/partner-site"

  name_prefix        = local.default_name
  service_definition = var.partner_site
  log_group_name     = local.task_log_group_name

  alb_map    = module.albs
  subnet_map = module.network.subnets

  # Just a placeholder for now
  backend_api_base = "http://localhost:3100"

  additional_tags = {
    ServiceType = "partner-site"
    ServiceName = var.partner_site.name
  }
}

module "backend_api" {
  source = "./service/backend"

  name_prefix        = local.default_name
  service_definition = var.backend_api
  log_group_name     = local.task_log_group_name

  alb_map    = module.albs
  subnet_map = module.network.subnets
  db         = module.db

  public_upload_bucket = aws_s3_bucket.public_uploads.bucket

  migration = var.backend_api.migration

  partners_portal_url = "https://partners.demo.doorway.housingbayarea.org/" # Placeholder

  additional_tags = {
    ServiceType = "backend-api"
    ServiceName = var.backend_api.name
  }
}
