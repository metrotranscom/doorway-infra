
module "service" {
  source = "../base-service"

  name_prefix  = var.name_prefix
  service_name = var.service_definition.name
  cpu          = var.service_definition.cpu
  ram          = var.service_definition.ram
  image        = var.service_definition.image
  port         = local.port

  alb_listener_arn = var.alb_listener_arn
  alb_sg_id        = var.alb_sg_id
  subnet_ids       = var.subnet_ids
  #subnet_ids       = [for subnet in module.network.private_subnets : subnet.id]

  env_vars = merge(
    tomap({
      # Core Bloom vars
      NEXTJS_PORT      = local.port,
      BACKEND_API_BASE = var.backend_api_base

      # AWS-specific vars
      PUBLIC_BUCKET_NAME = var.public_upload_bucket_name
      SECURE_BUCKET_NAME = var.secure_upload_bucket_name
      UPLOAD_PREFIX      = "${var.name_prefix}/${service_name}"
    }),
    var.service_definition.env_vars,
  )

  additional_tags = {
    ServiceName = var.service_definition.name
  }
}
