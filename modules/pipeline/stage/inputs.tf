
variable "name" {
  type        = string
  description = "The name of the pipeline"

  # validation {
  #   condition     = can(regex("^[\\w\\s\\.\\-]+$", var.name))
  #   error_message = "name can only contain letters, numbers, spaces, periods, underscores, and hyphens"
  # }
}

variable "name_prefix" {
  type        = string
  description = "An identifier to prepend to resource names"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name_prefix))
    error_message = "name_prefix can only contain letters, numbers, and hyphens"
  }
}

variable "actions" {
  type = list(object({
    name  = string
    type  = string
    order = number

    # Build vars
    policy_arns = optional(set(string))
    env_vars    = optional(map(string))
    buildspec   = optional(any)

    # Approval vars
    topic = optional(string)
  }))
  description = "The list of actions to perform in this stage"

  validation {
    condition     = alltrue([for action in var.actions : contains(["build", "approval"], action.type)])
    error_message = "Action type must be one of \"build\" or \"approval\""
  }

  validation {
    condition     = alltrue([for action in var.actions : action.type != "approval" || action.topic != null])
    error_message = "Actions of type \"approval\" must have a topic set"
  }

  validation {
    condition     = alltrue([for action in var.actions : action.type != "build" || action.buildspec != null])
    error_message = "Actions of type \"build\" must have buildspec set"
  }
}
