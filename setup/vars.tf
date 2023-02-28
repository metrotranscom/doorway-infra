
variable "aws_region" {
  type        = string
  description = "The region to use when deploying regional resources"

  validation {
    condition     = can(regex("^(us(-gov)?|ap|ca|cn|eu|sa)-(central|(north|south)?(east|west)?)-\\d$", var.aws_region))
    error_message = "Must be a valid AWS region"
  }
}

variable "project_name" {
  type        = string
  description = "Name of the project"

  validation {
    condition     = can(regex("^[\\w\\s\\.\\-]+$", var.project_name))
    error_message = "project_name can only contain letters, numbers, spaces, periods, underscores, and hyphens"
  }
}

variable "resource_prefix" {
  type        = string
  description = "An identifier prepended to resource names"

  validation {
    condition     = can(regex("^[\\w\\-]+$", var.resource_prefix))
    error_message = "resource_prefix can only contain letters, numbers, underscores, and hyphens"
  }
}

variable "is_production" {
  type        = bool
  default     = false
  description = "Whether this infrastructure is for a production or non-production environment"
}
