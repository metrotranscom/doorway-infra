
variable "name_prefix" {
  type        = string
  description = "The prefix to prepend to resource names"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name_prefix))
    error_message = "Variable name_prefix can only contain letters, numbers, and hyphens."
  }
}

variable "project_id" {
  type        = string
  description = "A project-specific identifier used to scope access to a specific project"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.project_id))
    error_message = "Variable project_id can only contain letters, numbers, and hyphens."
  }
}

variable "environment" {
  type        = string
  description = "The name of the environment, used to scope access to a specific environment"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.environment))
    error_message = "Variable environment can only contain letters, numbers, and hyphens."
  }
}

variable "infra_account_id" {
  type        = string
  description = "The ID of the AWS account where the Bloom infra is deployed for this environment"
}

variable "infra_region" {
  type        = string
  description = "The region where the Bloom infra is deployed for this environment"
}
