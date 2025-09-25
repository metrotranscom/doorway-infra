
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
  description = "The name to give to give to this ECR repo and its related resources"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name))
    error_message = "name can only contain letters, numbers, and hyphens"
  }
}

variable "scan_images" {
  type        = bool
  default     = false
  description = "Whether to scan images pushed to the ECR repo"
}

variable "source_account" {
  type        = string
  description = "The ID of the account where images will be pushed and/or pulled from"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.source_account))
    error_message = "source_account must be a valid AWS Account ID (12 numbers, no hyphens)"
  }
}
