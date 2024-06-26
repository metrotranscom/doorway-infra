
variable "name_prefix" {
  type        = string
  description = "The prefix to prepend to resource names"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name_prefix))
    error_message = "name_prefix can only contain letters, numbers, and hyphens"
  }
}

variable "task_arn" {
  type        = string
  description = "The ARN for the task definition"
}

variable "alb_map" {
  type = map(object({
    arn      = string
    dns_name = string
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

variable "service" {
  type = object({
    # The name of the service (must be unique)
    name = string

    # The group of subnets to run this service in
    subnet_group = string

    # The name of the cluster to run this service on
    cluster_name = string

    # This object tells the service which ALB listeners to add forwarding rules for
    albs = map(object({
      listeners = map(object({
        listen_on_alb_dns_name = optional(bool, false)
        domains                = list(string)
      }))
    }))

    # Values for controlling health check behavior on the target group.
    health_check = object({
      interval     = optional(number, 10)
      valid_status = optional(list(string), ["200"])
      path         = optional(string, "/")
      protocol     = optional(string, "HTTP")
      timeout      = optional(number, 5)

      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
    })

    scaling = optional(object({
      enabled = optional(bool, true)
      # The minimum number of instances to run
      min = optional(number, 1)

      # The maximum number of instance to run
      max = number

      # The number of instances to start with
      # If less than min, min is used instead, which is why we default to 0
      desired = optional(number, 0)

      metrics = map(object({
        name   = string
        target = number
      }))

      }), {
      enabled = false
      min     = 1
      desired = 1
      max     = 1
      metrics = {}
    })

    # Which port to send requests to
    port = optional(number, 80)

    # Which protocol to use for sending requests from ALB to container
    protocol = optional(string, "HTTP")

    # Which domains this service should respond to requests for
    #domains = list(string)
  })

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.service.name))
    error_message = "name can only contain letters, numbers, and hyphens"
  }

  validation {
    condition     = var.service.port > 0 && var.service.port <= 65535
    error_message = "port must be a number in the range 1-65535"
  }

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.service.protocol)
    error_message = "protocol must be either HTTP or HTTPS"
  }

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.service.health_check.protocol)
    error_message = "health_check.protocol must be either HTTP or HTTPS"
  }

  # TODO: add more health_check validation

  description = "An object containing information about the service"
}

variable "additional_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags to apply to service resources"
}
variable "vpc_id" {
  type = string

}
variable "security_group_id" {
  type = string

}
