

variable "service_name" {
  type        = string
  description = "The name of the service"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.service_name))
    error_message = "service_name can only contain letters, numbers, and hyphens"
  }
}

variable "name_prefix" {
  type        = string
  description = "The prefix to prepend to resource names"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name_prefix))
    error_message = "name_prefix can only contain letters, numbers, and hyphens"
  }
}

/*
variable "sdlc_stage" {
  type        = string
  description = "The stage of the software development lifecycle this service is in"
}
*/

variable "env_vars" {
  type        = map(string)
  description = "The environment variables to pass to your container"
}

variable "desired_count" {
  type        = number
  default     = 1
  description = "The desired number of running containers"
}

variable "min_count" {
  type        = number
  default     = 1
  description = "The minimum number of running containers"
}

variable "max_count" {
  type        = number
  default     = 10
  description = "The maximum number of running containers"
}

variable "cpu" {
  type        = number
  default     = 256
  description = "The number of CPU units to make available to each container"
}

variable "ram" {
  type        = number
  default     = 512
  description = "The amount of RAM to make available to each container"
}

variable "image" {
  type        = string
  default     = null
  description = "The fully-qualified name of the container image to use"
}

variable "port" {
  type        = number
  default     = 80
  description = "The port to send requests to"
}

// Host port and container port must be the same with the awsvpc network type
/* 
variable "host_port" {
  type        = number
  default     = 80
  description = "The port on the host to listen on"
}

variable "container_port" {
  type        = number
  default     = 80
  description = "The port on the container where the service will listen"
}
*/

variable "service_protocol" {
  type        = string
  default     = "HTTP"
  description = "The protocol for the ALB to use when communicating with the service"
}

/*
variable "alb_id" {
  type        = string
  description = "The ID of the ALB to accept requests from"
}
*/

variable "alb_listener_arn" {
  type        = string
  description = "The ARN of the ALB Listener to add this service to"
}

/*
variable "alb" {
  type = object({
    id = string
    listener_id = string
  })

  description = "Attributes" 
}
*/

variable "alb_sg_id" {
  type        = string
  description = "The ID of the ALB Security Group to permit access from"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The ID(s) of the subnet(s) to run this service in"
}

variable "host_patterns" {
  type        = list(string)
  default     = ["*.elb.amazonaws.com"]
  description = "Requests with a host header matching any of these patterns will be sent to this service"
}

/*
variable "path_patterns" {
  type        = list(string)
  default     = ["*"]
  description = "Requests with a path matching any of these patterns will be sent to this service"
}
*/

variable "additional_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags to apply to service resources"
}
