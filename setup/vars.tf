
variable "aws_region" {
  type        = string
  description = "The AWS region to use when deploying regional resources"

  validation {
    condition     = can(regex("^(us(-gov)?|ap|ca|cn|eu|sa)-(central|(north|south)?(east|west)?)-\\d$", var.aws_region))
    error_message = "Must be a valid AWS region."
  }
}

variable "project_name" {
  type        = string
  description = "Name of the project"

  validation {
    condition     = can(regex("^[\\w\\s\\.\\-]+$", var.project_name))
    error_message = "The project_name variable can only contain letters, numbers, spaces, periods, underscores, and hyphens."
  }
}


variable "project_id" {
  type        = string
  description = "A project-specific identifier prepended to resource names"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.project_id))
    error_message = "The project_id variable can only contain letters, numbers, and hyphens."
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
    error_message = "The variable 'environment' can only contain letters and numbers, must start with a letter, and must be 10 or fewer characters."
  }
}

variable "repos" {
  type = map(object({
    scan_images    = bool
    source_account = optional(string)
  }))

  description = "A map of objects containing information for creating ECR repos"
}
