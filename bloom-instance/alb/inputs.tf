
variable "name_prefix" {
  type        = string
  description = "The prefix to prepend to resource names"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name_prefix))
    error_message = "name_prefix can only contain letters, numbers, and hyphens"
  }
}

variable "name" {
  type        = string
  description = "The name to give to give to this ALB and its related resources"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name))
    error_message = "name can only contain letters, numbers, and hyphens"
  }
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to create ALB resources in"
}

variable "subnets" {
  type = map(list(object({
    id   = string
    cidr = string
  })))
  description = "A map of the available subnets"
}

variable "subnet_group" {
  type        = string
  description = "The identifier for the subnet group to place the ALB into"
}

variable "listeners" {
  type = map(object({
    port           = number
    default_action = optional(string)

    allowed_ips     = optional(list(string))
    allowed_subnets = optional(list(string))

    tls = optional(any)
  }))
  description = "The listeners to create"
}

variable "internal" {
  type        = bool
  default     = false
  description = "Whether this ALB is public or internal"
}

variable "enable_logging" {
  type        = bool
  default     = true
  description = "Whether to enable logging on this ALB"
}

variable "log_bucket" {
  type        = string
  description = "The S3 bucket to write ALB logs to"
}

variable "additional_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags to apply to ALB resources"
}

variable "cert_map" {
  type        = map(string)
  description = "ARNs for TLS certificates to apply to secure listeners"
}
