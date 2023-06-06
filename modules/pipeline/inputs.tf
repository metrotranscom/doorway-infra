
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
    name       = string
    is_primary = optional(bool, false)
    repo = object({
      name   = string
      branch = string
    })
  }))
  description = "The source locations for this pipeline to use"

  validation {
    condition     = sum([for source in var.sources : source.is_primary ? 1 : 0]) == 1
    error_message = "There must be exactly one primary source"
  }
}

variable "notification_topics" {
  type = map(object({
    emails = set(string)
  }))

  description = "Named groups of people to notify when a certain event occurs"
}

variable "notification_rules" {
  type = list(object({
    # Which topic to send notifications to 
    topic  = string
    detail = optional(string, "BASIC")
    on     = map(set(string))
  }))

  description = "Rules for triggering notifications on pipeline events"
}

variable "stages" {
  type = list(object({
    # The name of this environment
    name = string

    actions = list(any)
    # actions = list(object({
    #   name  = string
    #   type  = string
    #   order = number
    # }))

    # Whether this stage requires approval prior to deployment
    # approval = optional(object({
    #   required = optional(bool, true)
    #   topic    = string
    #   }), {
    #   required = false
    #   topic    = ""
    # })
  }))
  description = "The environments to deploy infra into"
}
