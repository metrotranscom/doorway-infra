
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
  default     = "default"
  description = "The name to use for resources"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name))
    error_message = "name can only contain letters, numbers, and hyphens"
  }
}

variable "is_public" {
  type        = bool
  default     = false
  description = "Whether this bucket and its contents should be publicly available (exercise caution)"
}
