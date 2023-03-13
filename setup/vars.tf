
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

# This variable is used to override default naming behavior.  By default, names
# are scoped by terraform.workspace if not "default", otherwise it will be set
# to "prod" if is_production is true or "nonprod" if false
variable "environment" {
  type        = string
  default     = "default"
  description = "The name of the environment"

  validation {
    condition     = can(regex("^[[:alpha:]][[:alnum:]]{0,10}$", var.environment))
    error_message = "environment can only contain letters and numbers, must start with a letter, and must be 10 or fewer characters"
  }
}

variable "scan_images" {
  type        = bool
  default     = false
  description = "Whether to scan images pushed to the ECR repo"
}
