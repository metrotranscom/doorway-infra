
variable "name_prefix" {
  type        = string
  description = "A prefix to be used when creating resources to provide a distinct, yet recognizable name"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name_prefix))
    error_message = "name_prefix can only contain letters, numbers, and hyphens"
  }
}

variable "log_group_name" {
  type        = string
  description = "The name of the CloudWatch Logs log group to use"
}

variable "alb_map" {
  # See ecs/service/inputs.tf for type structure
  type        = any
  description = "A map of available ALBs"
}

variable "dns" {
  # See ../service/inputs.tf for type structure
  type        = any
  description = "Values from the dns module"
}

variable "subnet_map" {
  # See ecs/service/inputs.tf for type structure
  type        = any
  description = "A map of available subnets"
}

variable "service_definition" {
  # See services/inputs.tf for type structure
  type = object({
    name    = string
    port    = optional(number)
    task    = any
    service = any
  })
  description = "A partner portal service definition object"
}

variable "backend_api_base" {
  type        = string
  description = "The base URL for the backend API"
}

variable "additional_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags to apply to public site resources"
}
