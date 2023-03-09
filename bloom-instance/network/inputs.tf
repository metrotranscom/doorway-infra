
variable "name" {
  type        = string
  default     = "default"
  description = "The name to use for subnet resources"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name))
    error_message = "name can only contain letters, numbers, and hyphens"
  }
}

variable "name_prefix" {
  type        = string
  description = "The prefix to prepend to resource names"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name_prefix))
    error_message = "name_prefix can only contain letters, numbers, and hyphens"
  }
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The IP addresses to allocate to our VPC"
}

variable "subnet_map" {
  type = object({
    public = list(object({
      az   = string
      cidr = string
    }))

    app = list(object({
      az   = string
      cidr = string
    }))

    data = list(object({
      az   = string
      cidr = string
    }))
  })
  description = "The subnets to create in our VPC"
}

variable "additional_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags to apply to our network resources"
}
