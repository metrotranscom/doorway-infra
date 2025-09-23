
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

variable "cert_map" {
  type        = map(string)
  description = "ARNs for TLS certificates to apply to secure listeners"
}

variable "cluster_name" {
  type        = string
  description = "The name of the ECS cluster to run this service in"
}

variable "service_definition" {
  # See services/inputs.tf for type structure
  type        = any
  description = "A public portal service definition object"
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
variable "alb_arn" {
  type = string

}
variable "site_urls" {
  type = list(string)

}
variable "cert_arn" {
  type = string

}
variable "vpc_id" {
  type = string

}
variable "security_group_id" {
  type = string

}
