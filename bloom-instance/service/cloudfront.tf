
resource "aws_cloudfront_distribution" "service" {
  count = local.cloudfront_enabled ? 1 : 0
  origin {
    origin_id   = local.cloudfront_origin_id
    domain_name = "<alb.dns_name>"
  }

  # Derived from known values
  target_origin_id = local.cloudfront_origin_id
  comment          = local.qualified_name

  # Configurable
  enabled     = local.cloudfront.enabled
  aliases     = local.cloudfront.domains
  price_class = local.cloudfront.price_class

  # Hardcoded
  viewer_protocol_policy = "redirect-to-https"

  logging_config {
    bucket          = "<logging_bucket.s3.amazonaws.com>)"
    prefix          = "cloudfront/${local.qualified_name}"
    include_cookies = false
  }

  viewer_certificate {
    acm_certificate_arn = "" # resolve from certs

    # Changing this to "vip" gets you a dedicated IP that will incur additional charges
    ssl_support_method = "sni-only"
  }

  default_cache_behavior {
    target_origin_id = local.cloudfront_origin_id
    allowed_methods  = local.cloudfront_default_cache.allowed_methods
    cached_methods   = local.cloudfront_default_cache.cached_methods

  }
}
