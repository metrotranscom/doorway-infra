
variable "subnets" {
  type = map(list(object({
    id   = string
    cidr = string
  })))
  description = "A map of available subnets"
}

variable "cert_map" {
  type        = map(string)
  description = "ARNs for TLS certificates to apply to secure listeners"
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

  validation {
    condition     = var.tls != null && !(var.tls.enable && var.tls.default_cert == null)
    error_message = "default_cert is required if tls.enable is true"
  }
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
