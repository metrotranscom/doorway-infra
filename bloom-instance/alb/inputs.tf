
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
  description = "The name to give to resources"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name))
    error_message = "name can only contain letters, numbers, and hyphens"
  }
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to create ALB resources in"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The IDs of the subnets to create the ALB in"
}

variable "listeners" {
  type = map(object({
    port        = number
    use_tls     = bool
    allowed_ips = list(string)
  }))
  default     = null
  description = "The listeners to create"

  validation {
    condition = alltrue([
      for l in var.listeners : l.port > 0 && l.port <= 65535
    ])
    error_message = "Port numbers must be in valid range"
  }
}

variable "internal" {
  type        = bool
  default     = false
  description = "Whether this ALB is public or internal"
}

variable "additional_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags to apply to ALB resources"
}
