
/*
variable "certs" {
  type        = map(string)
  description = "ARNs for TLS certificates to apply to secure listeners"
}
*/

variable "subnets" {
  type = map(object({
    id = string
  }))
  description = "A map of the available subnets"
}

variable "subnet_group" {
  type        = string
  description = "The identifier for the subnet group to place the ALB into"
}


variable "settings" {
  type = object({
    port             = number
    use_tls          = bool
    force_tls        = optional(bool)
    default_cert     = optional(string)
    additional_certs = optional(list(string))
    allowed_ips      = list(string)
    allowed_subnets  = list(string)
  })
  default     = null
  description = "The listeners to create"

  validation {
    condition     = var.defintion.port > 0 && var.defintion.port <= 65535
    error_message = "Port numbers must be in valid range"
  }

  validation {
    condition     = var.defintion.use_tls && var.defintion.default_cert == null
    error_message = "default_cert is required if use_tls is true"
  }
}

variable "additional_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags to apply to the listener"
}
