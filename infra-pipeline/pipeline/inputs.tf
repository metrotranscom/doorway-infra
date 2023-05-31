
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

variable "tf_root" {
  type = object({
    source = string
    path   = string
  })
  description = "The location (source repo and path) to run terraform commands"
}

variable "environments" {
  type = list(object({
    # The name of this environment
    name = string

    # Which terraform workspace to use when deploying
    workspace = string

    # The location of the tvfars file
    var_file = object({
      # Source name
      source = string
      # Path
      path = string
    })

    # ARNs of IAM policies to attach to the CodeBuild role
    policy_arns = list(string)

    # Environment variables to pass to the build project
    env_vars = map(string)

    # Whether this stage requires approval prior to deployment
    approval = optional(object({
      required  = optional(bool, true)
      approvers = set(string)
      }), {
      required  = false
      approvers = []
    })
  }))
  description = "The environments to deploy infra into"
}
