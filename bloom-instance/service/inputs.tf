
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
    zone_id  = string

  }))

  description = "The available ALBs"
}

variable "cert_map" {
  type        = map(string)
  description = "ARNs for TLS certificates to apply to secure listeners"
}

variable "dns" {
  type = object({
    default_ttl = number
    zone_map    = map(string)
  })

  description = "Values from the dns module"
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

variable "cluster_name" {
  type        = string
  description = "The name of the ECS cluster to run this service in"
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
variable "cloudfront" {
  type        = any
  default     = null
  description = "The object defining settings for the CloudFront distribution"
}
variable "vpc_id" {
  type = string

}
variable "security_group_id" {
  type = string

}
