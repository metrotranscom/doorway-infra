
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

variable "port" {
  type        = number
  description = "The port to listen on"

  validation {
    condition     = var.port > 0 && var.port <= 65535
    error_message = "Port number must be in valid range"
  }
}

/*
variable "settings" {
  type = object({
    ///port = number
    //use_tls          = bool
    //force_tls        = optional(bool)
    //default_cert     = optional(string)
    //additional_certs = optional(list(string))
    allowed_ips     = optional(list(string), [])
    allowed_subnets = optional(list(string), [])
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
*/

variable "default_action" {
  type    = string
  default = "404"

  validation {
    condition     = contains(["force-tls", "404"], var.default_action)
    error_message = "default_action must be one of [force-tls, 404]"
  }
}

variable "tls" {
  type = object({
    enable           = optional(bool, true)
    default_cert     = string
    additional_certs = optional(list(string))
  })

  default     = null
  description = "TLS settings"
}

variable "allowed_ips" {
  type        = list(string)
  description = "CIDR blocks to allow access from"
}

variable "allowed_subnets" {
  type        = list(string)
  description = "Subnet groups to allow access from"
}

variable "additional_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags to apply to the listener"
}
