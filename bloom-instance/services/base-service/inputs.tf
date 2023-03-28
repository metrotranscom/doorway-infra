
variable "name_prefix" {
  type        = string
  description = "The prefix to prepend to resource names"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name_prefix))
    error_message = "name_prefix can only contain letters, numbers, and hyphens"
  }
}

variable "service_definition" {
  type = object({
    # The name of the service (must be unique)
    name = string

    # The identifier for the ALB to use (ie "default")
    # This is used elsewhere to look up ALB info
    alb = string

    # The amount of CPU to allocate to the service
    cpu = optional(number, 256)

    # The amount of memory to allocate to the service
    ram = optional(number, 512)

    # The container image to use
    image = string

    # Which port to send requests to
    port = optional(number, 80)

    # Which protocol to use for sending requests from ALB to container
    protocol = optional(string, "HTTP")

    # Which domains this service should respond to requests for
    domains = list(string)

    # Environment variables to pass to the running containers
    env_vars = map(string)

    # Values for controlling health check behavior on the target group.
    health_check = object({
      #enabled      = optional(bool, true)
      interval     = optional(number, 10)
      valid_status = optional(list(string), ["200"])
      path         = optional(string, "/")
      protocol     = optional(string, "HTTP")
      timeout      = optional(number, 5)

      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
    })
  })

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.service_definition.name))
    error_message = "name can only contain letters, numbers, and hyphens"
  }

  validation {
    #condition     = var.service_definition.cpu % 128 != 0 || var.service_definition.cpu > 16384
    condition     = contains([256, 512, 1024, 2048, 4096, 8192, 16384], var.service_definition.cpu)
    error_message = "cpu must be one of the valid options for Fargate (see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
  }

  validation {
    # More advanced validation than this would be prone to breakage in the future
    condition     = var.service_definition.ram % 512 == 0 || var.service_definition.ram > (120 * 1024)
    error_message = "ram must be one of the valid options for the specified cpu (see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
  }

  validation {
    condition     = var.service_definition.port > 0 && var.service_definition.port <= 65535
    error_message = "port must be a number in the range 1-65535"
  }

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.service_definition.protocol)
    error_message = "protocol must be either HTTP or HTTPS"
  }

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.service_definition.health_check.protocol)
    error_message = "health_check.protocol must be either HTTP or HTTPS"
  }

  # TODO: add more health_check validation 

  description = "An object containing information about the service"
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

variable "additional_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags to apply to service resources"
}

variable "task_role_arn" {
  type        = string
  description = "The IAM role for the task to assume"
}
