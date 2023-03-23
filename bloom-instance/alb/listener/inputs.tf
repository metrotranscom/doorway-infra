
variable "subnets" {
  type = map(list(object({
    id   = string
    cidr = string
  })))
  description = "A map of available subnets"
}

variable "alb_arn" {
  type        = string
  description = "The ALB to attach the listener to"
}

variable "security_group_id" {
  type        = string
  description = "The Security Group to attach ingress rules to"
}

variable "settings" {
  type = object({
    port             = number
    use_tls          = bool
    force_tls        = optional(bool)
    default_cert     = optional(string)
    additional_certs = optional(list(string))
    allowed_ips      = optional(list(string), [])
    allowed_subnets  = optional(list(string), [])
  })
  description = "The listeners to create"

  validation {
    condition     = var.settings.port > 0 && var.settings.port <= 65535
    error_message = "Port numbers must be in valid range"
  }

  validation {
    condition     = !(var.settings.use_tls && var.settings.default_cert == null)
    error_message = "default_cert is required if use_tls is true"
  }
}

variable "additional_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags to apply to the listener"
}
