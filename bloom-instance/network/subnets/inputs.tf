
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

variable "subnet_mappings" {
  type = list(object({
    az   = string
    cidr = string
  }))

  description = "The mappings between subnet and AZ"
}

variable "gateway_type" {
  type        = string
  default     = "none"
  description = "The type of gateway to attach to the route table for this group of subnets"

  validation {
    condition     = contains(["none", "igw", "ngw"], var.gateway_type)
    error_message = "Valid gateway types are (none, igw, ngw)"
  }
}

variable "vpc_id" {
  type        = string
  default     = null
  description = "The ID of the VPC to place the subnets in"
}

variable "ngw_id" {
  type        = string
  default     = null
  description = "The ID for the NAT Gateway to attach (if any). Required if gateway_type is \"ngw\", ignored otherwise"
}

variable "igw_id" {
  type        = string
  default     = null
  description = "The ID for the Internet Gateway to attach (if any). Required if gateway_type is \"igw\", ignored otherwise"
}

variable "additional_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags to apply to our network resources"
}
