
variable "name" {
  type        = string
  description = "The name of this repository"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name))
    error_message = "name can only contain letters, numbers, and hyphens"
  }
}

variable "name_prefix" {
  type        = string
  description = "An identifier to prepend to resource names"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name_prefix))
    error_message = "name_prefix can only contain letters, numbers, and hyphens"
  }
}

variable "region" {
  type        = string
  description = "The region this repository is in"
}

variable "account" {
  type        = string
  description = "The account this repository is in"
}

variable "namespace" {
  type        = string
  description = "The namepace for this repository"

  validation {
    condition     = can(regex("^[[:alnum:]\\-\\/]+$", var.namespace))
    error_message = "namespace can only contain letters, numbers, hyphens, and forward slashes"
  }
}
