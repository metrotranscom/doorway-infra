
variable "name_prefix" {
  type        = string
  description = "A prefix to be used when creating resources to provide a distinct, yet recognizable name"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name_prefix))
    error_message = "name_prefix can only contain letters, numbers, and hyphens"
  }
}

variable "service_definition" {
  type = object({
    name     = string
    cpu      = optional(number)
    ram      = optional(number)
    image    = string
    port     = optional(number)
    domains  = list(string)
    env_vars = map(string)
  })

  description = "A public portal service definition object"
}

variable "alb_listener_arn" {
  type        = string
  description = "The ARN of the ALB Listener to add this service to"
}

variable "alb_sg_id" {
  type        = string
  description = "The ID of the ALB Security Group to permit access from"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The ID(s) of the subnet(s) to run this service in"
}

variable "backend_api_base" {
  type        = string
  description = "The base URL for the backend API"
}

variable "public_upload_bucket" {
  type        = string
  description = "The name of the bucket to use for publicly available file uploads"
}

variable "secure_upload_bucket" {
  type        = string
  description = "The name of the bucket to use for secure file uploads"
}

variable "additional_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags to apply to public site resources"
}
