
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

variable "codestar_connection_arn" {
  type        = string
  description = "The ARN for the CodeStar Connection to use"
}

variable "sources" {
  type = map(object({
    name = string
    repo = object({
      name   = string
      branch = string
    })
  }))
  description = "The source locations for this pipeline to use"
}

variable "environments" {
  type = list(object({
    name        = string
    workspace   = string
    config_path = string
    policy_arns = list(string)
    approval = optional(object({
      required  = optional(bool, true)
      approvers = list(string)
      }), {
      required  = false
      approvers = []
    })
  }))
  description = "The environments to deploy infra into"
}
