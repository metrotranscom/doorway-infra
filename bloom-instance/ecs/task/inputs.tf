
variable "name_prefix" {
  type        = string
  description = "The prefix to prepend to resource names"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name_prefix))
    error_message = "name_prefix can only contain letters, numbers, and hyphens"
  }
}

variable "task" {
  type = object({
    # The name of the service (must be unique)
    name = string

    # The amount of CPU to allocate to the service
    cpu = optional(number, 256)

    # The amount of memory to allocate to the service
    ram = optional(number, 512)

    # The container image to use
    image = string

    # Which port to send requests to
    port = optional(number, 80)

    # Environment variables to pass to the running containers
    env_vars = map(string)
  })

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.task.name))
    error_message = "name can only contain letters, numbers, and hyphens"
  }

  validation {
    #condition     = var.service_definition.cpu % 128 != 0 || var.service_definition.cpu > 16384
    condition     = contains([256, 512, 1024, 2048, 4096, 8192, 16384], var.task.cpu)
    error_message = "cpu must be one of the valid options for Fargate (see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
  }

  validation {
    # More advanced validation than this would be prone to breakage in the future
    condition     = var.task.ram % 512 == 0 || var.task.ram > (120 * 1024)
    error_message = "ram must be one of the valid options for the specified cpu (see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
  }

  validation {
    condition     = var.task.port > 0 && var.task.port <= 65535
    error_message = "port must be a number in the range 1-65535"
  }

  description = "An object containing information about the task"
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
