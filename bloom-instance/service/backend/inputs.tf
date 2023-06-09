
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

variable "internal_url_path" {
  type = tuple([
    string, # ALB name
    string, # listener name
    number  # index of domain/url
  ])
  description = "Which URL to provide to other services in the format [alb_name, listener_name, url_index]"
}

variable "partners_portal_url" {
  type        = string
  description = "The URL to the partners portal, for injecting into email templates"
}

variable "public_upload_bucket" {
  type        = string
  description = "The name of the bucket to use for publicly available file uploads"
}

variable "db" {
  type = object({
    host     = string
    port     = number
    username = string
    db_name  = string

    connection_string = string
    security_group_id = string
    secret_arn        = string
  })
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

variable "migration" {
  # See ecs/task/inputs.tf for type structure
  type = object({
    cpu   = number
    ram   = number
    image = string
  })

  description = "A partial representation of the task definition for running migration jobs"
}

variable "additional_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags to apply to public site resources"
}
