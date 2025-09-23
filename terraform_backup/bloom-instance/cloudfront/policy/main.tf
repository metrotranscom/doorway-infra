
resource "aws_cloudfront_cache_policy" "policy" {
  name    = "${var.name_prefix}-${var.policy.name}"
  comment = var.policy.comment

  default_ttl = var.policy.ttl.default
  max_ttl     = var.policy.ttl.max
  min_ttl     = var.policy.ttl.min

  parameters_in_cache_key_and_forwarded_to_origin {

    enable_accept_encoding_brotli = var.policy.accept_brotli
    enable_accept_encoding_gzip   = var.policy.accept_gzip

    cookies_config {
      cookie_behavior = var.policy.cookies.include

      cookies {
        items = var.policy.cookies.names
      }
    }

    headers_config {
      header_behavior = var.policy.headers.include

      headers {
        items = var.policy.headers.names
      }
    }

    query_strings_config {
      query_string_behavior = var.policy.query.include

      query_strings {
        items = var.policy.query.names
      }
    }
  }
}


