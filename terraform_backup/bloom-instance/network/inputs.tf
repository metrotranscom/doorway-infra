
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

variable "subnet_groups" {
  type = map(
    object({
      # The name to give to subnets in this group
      name = string

      # Whether this subnet group is public
      # Highlander rules: there can be only one
      is_public = optional(bool, false)

      # Whether this group of subnets needs an NGW
      # Mutually exclusive with is_public
      use_ngw = optional(bool, false)

      # The AZ/CIDR mappings for each subnet in this group
      subnets = list(
        object({
          az   = string
          cidr = string
        })
      )
    })
  )

  description = "The subnets to create in our VPC"

  validation {
    condition = alltrue(
      [
        for group in var.subnet_groups :
        !group.use_ngw || (group.use_ngw && !group.is_public)
      ]
    )
    error_message = "Subnet groups using NGWs (use_ngw=true) cannot be marked as public (is_public=true)"
  }

  validation {
    condition     = sum([for group in var.subnet_groups : group.is_public ? 1 : 0]) == 1
    error_message = "There must be exactly one public subnet group (is_public=true)"
  }
}

variable "additional_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags to apply to our network resources"
}
