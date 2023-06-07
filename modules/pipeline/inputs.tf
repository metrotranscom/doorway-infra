
variable "name" {
  type        = string
  description = "The name of the pipeline"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name))
    error_message = "name can only contain letters, numbers, and hyphens"
  }
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

variable "build_policy_arns" {
  type        = set(string)
  description = "Additional policy ARNs to pass to every build action in this pipeline"
}

variable "build_env_vars" {
  type        = map(string)
  description = "Additional environmental variables to pass to every build action in this pipeline"
}

variable "stages" {
  type = list(object({
    # The name of this environment
    name = string
    # An optional human-readable label to apply to the stage
    label = optional(string)

    # Additional policy ARNs to pass to every build action in this stage
    build_policy_arns = optional(set(string), [])
    # Additional env vars to pass to every build action in this stage
    build_env_vars = optional(map(string), {})

    default_network = optional(any)

    # This must match the type definition in ./stage/inputs.tf
    actions = list(object({
      name  = string
      label = optional(string)
      type  = string
      order = number

      # Build vars
      compute_type  = optional(string)
      image         = optional(string)
      build_timeout = optional(number)
      policy_arns   = optional(set(string))
      env_vars      = optional(map(string))
      privileged    = optional(bool)

      vpc = optional(object({
        use             = optional(bool, false)
        vpc_id          = optional(string, "")
        subnets         = optional(set(string), [])
        security_groups = optional(set(string), [])
        }), {
        use             = false,
        vpc_id          = ""
        subnets         = []
        security_groups = []
      })

      buildspec = optional(object({
        source = string
        path   = string
      }))

      # Approval vars
      topic = optional(string)
    }))
  }))
  description = "The environments to deploy infra into"
}
