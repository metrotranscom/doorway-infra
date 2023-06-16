
variable "name_prefix" {
  type        = string
  description = "The prefix to prepend to resource names"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name_prefix))
    error_message = "name_prefix can only contain letters, numbers, and hyphens"
  }
}

variable "name" {
  # Validation is skipped be cause it is being handled elsewhere
  # See ecs/service/inputs.tf
  type        = string
  description = "The name to give to this service"
}

variable "port" {
  # Validation is skipped be cause it is being handled elsewhere
  # See ecs/service/inputs.tf
  type        = number
  description = "The port to run this service on"
}

variable "log_group_name" {
  type        = string
  description = "The name of the CloudWatch Logs log group to use"
}

variable "alb_map" {
  type = map(object({
    arn      = string
    dns_name = string
    security_group = object({
      id = string
    })
    listeners = map(object({
      arn       = string
      port      = number
      is_secure = bool
    }))
  }))

  description = "The available ALBs"
}

variable "subnet_map" {
  type = map(list(object({
    id   = string
    cidr = string
  })))
  description = "A map of the available subnets"
}

variable "task" {
  # See ecs/task/inputs.tf for type and validation rules
  type        = any
  description = "The object defining settings for the task component"
}

variable "service" {
  # See ecs/service/inputs.tf for type and validation rules
  type        = any
  description = "The object defining settings for the service component"
}

variable "cloudfront" {
  type = optional(object({
    enabled     = optional(bool, true)
    domains     = set(string)
    price_class = optional(string, "PriceClass_100")
    certificate = string

    cache = map(object({
      viewer_protocol_policy = optional(string, "redirect-to-https")
      compress               = optional(bool, false)

      allowed_methods = list(string)
      cached_methods  = list(string)

      ttl = object({
        min     = number
        max     = number
        default = number
      })

      forward = object({
        query_string = bool
        headers      = set(string)
        cookies      = set(string)
      })

    }))
  }))
  description = "The object defining settings for the service component"

  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.cloudfront.price_class)
    error_message = "cloudfront.price_class must be one of [PriceClass_All, PriceClass_200, PriceClass_100]"
  }

  validation {
    condition     = lookup(var.cloudfront.cache, "default", null) != null
    error_message = "cloudfront.cache must contain an entry named \"default\""
  }
}

variable "additional_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags to apply to service resources"
}

variable "task_role_arn" {
  type        = string
  description = "The IAM role for the task to assume"
}
