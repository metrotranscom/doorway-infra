
variable "name_prefix" {
  # Validation is skipped be cause it is being handled elsewhere
  type        = string
  description = "The prefix to prepend to resource names"
}

variable "name" {
  # Validation is skipped be cause it is being handled elsewhere
  type        = string
  description = "The name to give to this CloudFront distribution"
}

variable "alb_map" {
  type = map(object({
    arn      = string
    dns_name = string
  }))

  description = "The available ALBs"
}

variable "cert_map" {
  type        = map(string)
  description = "ARNs for TLS certificates to apply to secure listeners"
}
variable "domains" {
  type = list(string)

}
variable "distribution" {
  type = object({
    enabled     = optional(bool, true)
    price_class = optional(string, "PriceClass_100")

    certificate = object({
      arn = string
    })

    # Note: This module only supports ALB origins right now
    origin = object({
      alb = string
    })

    restrictions = object({
      geo = object({
        type      = string
        locations = optional(list(string), [])
      })
    })

    cache = map(object({
      viewer_protocol_policy = optional(string, "redirect-to-https")
      compress               = optional(bool, false)
      order                  = optional(number, 1)

      allowed_method_set = string
      cached_method_set  = string

      # Either policy_id or policy is required
      policy_id = optional(string)
      policy = optional(object({
        name    = string
        comment = string

        accept_brotli = optional(bool, false)
        accept_gzip   = optional(bool, false)

        ttl = object({
          min     = number
          max     = number
          default = number
        })

        cookies = object({
          include = string
          names   = optional(list(string))
        })

        headers = object({
          include = string
          names   = optional(list(string))
        })

        query = object({
          include = string
          names   = optional(list(string))
        })
      }))
    }))
  })
  description = "The object defining settings for the service component"

  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.distribution.price_class)
    error_message = "price_class must be one of [PriceClass_All, PriceClass_200, PriceClass_100]"
  }

  validation {
    condition     = contains(["none", "whitelist", "blacklist"], var.distribution.restrictions.geo.type)
    error_message = "restrictions.geo.type must be one of [none, whitelist, blacklist]"
  }

  validation {
    condition     = var.distribution.restrictions.geo.type == "none" || length(var.distribution.restrictions.geo.locations) > 0
    error_message = "restrictions.geo.locations must be set and non-empty if type is not none"
  }

  validation {
    condition     = lookup(var.distribution.cache, "default", null) != null
    error_message = "cache must contain an entry named \"default\""
  }

  validation {
    condition = alltrue([
      for cache in var.distribution.cache :
      !(cache.policy_id == null && cache.policy == null)
    ])
    error_message = "Either cache.policy_id or cache.policy must be set on all cache objects"
  }

  validation {
    condition = alltrue([
      for cache in var.distribution.cache :
      contains(["get", "with-options", "all"], cache.allowed_method_set)
    ])
    error_message = "cache.allowed_method_set must be one of [get, with-options, all]"
  }

  validation {
    condition = alltrue([
      for cache in var.distribution.cache :
      contains(["get", "with-options"], cache.cached_method_set)
    ])
    error_message = "cache.cached_method_set must be one of [get, with-options]"
  }
}
