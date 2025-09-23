
variable "name_prefix" {
  # Validation is skipped be cause it is being handled elsewhere
  type        = string
  description = "The prefix to prepend to resource names"
}

variable "policy" {
  type = object({
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
  })

  description = "The configuration for the policy to create"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.policy.name))
    error_message = "name can only contain letters, numbers, and hyphens"
  }

  validation {
    condition     = contains(["none", "whitelist", "allExcept", "all"], var.policy.cookies.include)
    error_message = "policy.cookies.include must be one of [none, whitelist, allExcept, all]"
  }

  validation {
    condition     = contains(["none", "whitelist"], var.policy.headers.include)
    error_message = "policy.headers.include must be one of [none, whitelist]"
  }

  validation {
    condition     = contains(["none", "whitelist", "allExcept", "all"], var.policy.query.include)
    error_message = "policy.query.include must be one of [none, whitelist, allExcept, all]"
  }
}
