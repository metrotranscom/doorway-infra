
variable "name" {
  type        = string
  description = "The name of the stage"

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

variable "label" {
  type        = string
  description = "A human-readable label to apply to the stage"

  validation {
    condition     = can(regex("^[\\w\\.\\-]+$", var.label))
    error_message = "label can only contain letters, numbers, underscores, periods, and hyphens"
  }
}

variable "notification_topics" {
  type = map(object({
    topic_arn = string
  }))
  description = "A map of topics to send notifications to"
}

variable "default_network" {
  type = object({
    vpc_id          = string
    subnets         = set(string)
    security_groups = set(string)
  })

  description = "An optional VPC configuration to apply to each build action in this stage"
}

variable "build_actions" {
  # This must match the type definition in ../inputs.tf
  type = list(object({
    name  = string
    label = optional(string)
    order = number

    compute_type = optional(string, "BUILD_GENERAL1_SMALL")
    image        = optional(string, "aws/codebuild/standard:6.0")
    timeout      = optional(number, 15)
    privileged   = optional(bool, false)

    vpc = object({
      use             = bool
      vpc_id          = string
      subnets         = set(string)
      security_groups = set(string)
    })

    policy_arns = optional(set(string), [])
    env_vars    = optional(map(string), {})
    secret_arns = optional(map(string), {})

    buildspec = string
  }))
  description = "The list of build actions to perform in this stage"
}

variable "approval_actions" {
  # This must match the type definition in ../inputs.tf
  type = list(object({
    name  = string
    order = number
    label = optional(string)
    topic = string
  }))
  description = "The list of approval actions to perform in this stage"
}

variable "build_policy_arns" {
  type        = set(string)
  description = "Build policy ARNs to pass to every build action in this stage"
}

variable "build_env_vars" {
  type        = map(string)
  description = "Environmental variables to pass to every build action in this stage"
}

# variable "actions" {
#   # This must match the type definition in ../inputs.tf
#   type = list(object({
#     name  = string
#     type  = string
#     order = number

#     # Build vars
#     policy_arns = optional(set(string))
#     env_vars    = optional(map(string))
#     buildspec = optional(object({
#       source = string
#       path   = string
#     }))

#     # Approval vars
#     topic = optional(string)
#   }))
#   description = "The list of actions to perform in this stage"

#   validation {
#     condition     = alltrue([for action in var.actions : contains(["build", "approval"], action.type)])
#     error_message = "Action type must be one of \"build\" or \"approval\""
#   }

#   validation {
#     condition     = alltrue([for action in var.actions : action.type != "approval" || action.topic != null])
#     error_message = "Actions of type \"approval\" must have a topic set"
#   }

#   validation {
#     condition     = alltrue([for action in var.actions : action.type != "build" || action.buildspec != null])
#     error_message = "Actions of type \"build\" must have buildspec set"
#   }
# }
