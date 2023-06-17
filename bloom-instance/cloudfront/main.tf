
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

  distribution       = var.distribution
  cloudfront_enabled = local.distribution.enabled

  # Origin
  origin_id           = "${local.qualified_name}-default"
  origin_alb_name     = local.distribution.origin.alb
  origin_alb          = var.alb_map[local.origin_alb_name]
  origin_alb_dns_name = local.origin_alb.dns_name

  # Certificates
  cert_name = var.distribution.certificate.name
  cert_arn  = var.cert_map[local.cert_name]


  # The default cache has the same data shape, but is treated differently
  default_cache = local.distribution.cache.default
  # The other cache rules need to be separated out
  other_caches = { for path, cache in local.distribution.cache : path => cache if path != "default" }

  # Cache policies that need to be created
  cache_policies_to_create = {
    for name, cache in local.distribution.cache : name => cache.policy if cache.policy != null
  }

  # The policy IDs that were provided directly
  provided_cache_policy_ids = {
    for name, cache in local.distribution.cache : name => cache.policy_id if cache.policy_id != null
  }

  # The policy IDs for policies we created
  generated_cache_policy_ids = {
    for name, policy in module.policies : name => policy.id
  }

  # All policy IDs, provided and generated
  policy_ids = merge(local.provided_cache_policy_ids, local.generated_cache_policy_ids)
}

module "policies" {
  source   = "./policy"
  for_each = local.cache_policies_to_create

  name_prefix = local.qualified_name
  policy      = each.value
}

resource "aws_cloudfront_distribution" "main" {
  origin {
    origin_id   = local.origin_id
    domain_name = local.origin_alb.dns_name
  }

  # Derived from known values
  comment = local.qualified_name

  # Configurable
  enabled     = local.distribution.enabled
  aliases     = local.distribution.domains
  price_class = local.distribution.price_class

  # logging_config {
  #   bucket          = "<logging_bucket.s3.amazonaws.com>"
  #   prefix          = "cloudfront/${local.qualified_name}"
  #   include_cookies = false
  # }

  viewer_certificate {
    acm_certificate_arn = local.cert_arn

    # Changing this to "vip" gets you a dedicated IP that will incur additional charges
    ssl_support_method = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = var.distribution.restrictions.geo.type
      locations        = var.distribution.restrictions.geo.locations
    }
  }

  default_cache_behavior {
    target_origin_id       = local.origin_id
    allowed_methods        = local.default_cache.allowed_methods
    cached_methods         = local.default_cache.cached_methods
    viewer_protocol_policy = local.default_cache.viewer_protocol_policy

    cache_policy_id = local.policy_ids.default
  }

  dynamic "ordered_cache_behavior" {
    for_each = {
      # Put cache.order at the beginning to apply caching behavior in the expected order
      for path, cache in local.other_caches : "${cache.order}-${path}" => merge(
        cache,
        # Add path directly to value since we aren't using it as the key anymore
        { path_pattern : path }
      )
    }

    iterator = cache

    content {
      target_origin_id       = local.origin_id
      allowed_methods        = cache.value.allowed_methods
      cached_methods         = cache.value.cached_methods
      viewer_protocol_policy = cache.value.viewer_protocol_policy
      path_pattern           = cache.value.path_pattern

      cache_policy_id = local.policy_ids[cache.value.path_pattern]
    }
  }
}
