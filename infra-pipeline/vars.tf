
variable "aws_region" {
  type        = string
  description = "The AWS region to use when deploying regional resources"

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

# This var is only set on resource tags. Standard tag naming restrictions apply
variable "owner" {
  type        = string
  description = "The owner of the resources created via these templates"

  validation {
    condition     = can(regex("^[\\w\\s\\.\\-\\:\\/\\=\\+@]{1,255}$", var.owner))
    error_message = "owner can only contain letters, numbers, spaces, and these special characters: _ . : / = + - @"
  }
}

variable "project_id" {
  type        = string
  description = "A project-specific identifier prepended to resource names"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.project_id))
    error_message = "project_id can only contain letters, numbers, and hyphens"
  }
}

variable "codestar_connection_arn" {
  type        = string
  description = "The ARN for the CodeStar Connection to use"
}

variable "pipeline" {
  type = object({
    # See ./pipeline/inputs.tf for object structures
    sources      = any
    environments = any
  })
}
