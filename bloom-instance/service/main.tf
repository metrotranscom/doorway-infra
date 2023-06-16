
locals {
  qualified_name = "${var.name_prefix}-${var.name}"

  cloudfront_test = {
    enabled = true
    domains = ["partners.chriscasto.doorway.housingbayarea.org"]
    #origin       = "" => alb.dns_name
    #comment      = "" => doorway-dev-partners
    #default_root = "" ? probably not needed
    price_class = "PriceClass_100" #PriceClass_All, PriceClass_200, PriceClass_100

    certificate = "doorway"

    default_restrictions : {
      geo : {
        type      = "whitelist"
        locations = ["US"]
      }
    }

    cache = {
      default = {
        viewer_protocol_policy = "redirect-to-https"
        compress               = true

        ttl = {
          min : 0
          max : 86400
          default : 60
        }

        allowed_methods = ["GET", "POST"]
        cached_methods  = ["GET"]

        forward = {
          query_string = false
          headers      = []
          cookies      = ["all"]
        }

      }

      rules = {
        "/listings/*" : {

        }

      }
    }
  }

  cloudfront         = local.cloudfront_test
  cloudfront_enabled = local.cloudfront.enabled

  cloudfront_origin_id = "${local.qualified_name}-default"

  # The default cache has the same data shape, but is treated differently
  cloudfront_default_cache = local.cloudfront.cache.default
  # The other cache rules need to be separated out
  cloudfront_other_caches = [for path, cache in local.cloudfront.cache : cache if path != "default"]
}

module "task" {
  source = "../ecs/task"

  name_prefix    = var.name_prefix
  task_role_arn  = var.task_role_arn
  log_group_name = var.log_group_name

  task = merge(
    var.task,
    {
      name = var.name
      port = var.port
    }
  )

  additional_tags = var.additional_tags
}

module "service" {
  source = "../ecs/service"

  name_prefix = var.name_prefix
  alb_map     = var.alb_map
  subnet_map  = var.subnet_map
  task_arn    = module.task.arn

  service = merge(
    var.service,
    {
      name = var.name
      port = var.port
    }
  )

  additional_tags = var.additional_tags
}
