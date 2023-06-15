variable "project_name" {
  type        = string
  description = "A human-readable name for this project. Can be changed if needed"

  validation {
    condition     = can(regex("^[\\w\\s\\.\\-]+$", var.project_name))
    error_message = "project_name can only contain letters, numbers, spaces, periods, underscores, and hyphens"
  }
}

variable "project_id" {
  type        = string
  description = "A unique, immutable identifier for this project"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.project_id))
    error_message = "project_id can only contain letters, numbers, and hyphens"
  }
}

variable "application_name" {
  type        = string
  description = "The name for the application deployed"

  validation {
    condition     = can(regex("^[\\w\\s\\.\\-]+$", var.application_name))
    error_message = "application_name can only contain letters, numbers, spaces, periods, underscores, and hyphens"
  }
}

# This var is only set on resource tags. Standard tag naming restrictions apply
variable "owner" {
  type        = string
  description = "The owner of the resources created via these templates"

  validation {
    condition     = can(regex("^[\\w\\s\\.\\-\\:\\/\\=\\+@]{1,255}$", var.owner))
    error_message = "owner can only contain letters, numbers, spaces, and these special characters: _ . : / = + - @"
  }
}

variable "aws_region" {
  type        = string
  description = "The region to use when deploying regional resources"

  validation {
    condition     = can(regex("^(us(-gov)?|ap|ca|cn|eu|sa)-(central|(north|south)?(east|west)?)-\\d$", var.aws_region))
    error_message = "Must be a valid AWS region"
  }
}

variable "gh_codestar_conn_name" {
  type        = string
  description = "The github/AWS Codestar connection resource for the repo. This allows AWS to connect to the github repo"
  validation {
    # Not comprehsnsive. Only checks it's non empty.
    condition     = can(regex("^[[:alnum:]\\-]+$", var.gh_codestar_conn_name))
    error_message = "Branch name can't be empty."
  }
}

variable "pipeline" {
  type = object({
    name = string
    # See ../modules/pipeline/inputs.tf for object structures
    sources = any

    # From ../modules/pipeline/inputs.tf
    # Necessary to avoid typing issues with "any" and lists
    stages = set(object({
      # The name of this environment
      name = string
      # An optional human-readable label to apply to the stage
      label = optional(string)

      # Additional policy ARNs to pass to every build action in this stage
      build_policy_arns = optional(set(string), [])
      # Additional env vars to pass to every build action in this stage
      build_env_vars = optional(map(string), {})

      default_network = optional(object({
        vpc_id          = string
        subnets         = set(string)
        security_groups = set(string)
        }), {
        vpc_id          = ""
        subnets         = []
        security_groups = []
      })

      # This is the same as in ../modules/pipeline/inputs.tf with exceptions noted
      actions = list(object({
        # These are new
        ecr_repo_access = optional(map(list(string)), {})

        # These are from the module
        name  = string
        label = optional(string)
        type  = string
        order = number

        compute_type = optional(string)
        image        = optional(string)
        timeout      = optional(number)
        policy_arns  = optional(set(string), [])
        env_vars     = optional(map(string), {})
        privileged   = optional(bool)
        secret_arns  = optional(map(string), {})

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

        buildspec = optional(string)

        # Approval vars
        topic = optional(string)
      }))
    }))

    notification_topics = any
    notify              = any
    build_policy_arns   = optional(set(string), [])
    build_env_vars      = optional(map(string), {})
  })

  description = "Settings for the pipeline"
}

variable "ecr" {
  type = object({
    default_region  = optional(string)
    default_account = optional(string)

    repo_groups = map(object({
      region    = optional(string)
      account   = optional(string)
      namespace = string
      repos     = set(string)
    }))
  })

  description = "Information about available ECR repos, used for passing repo info to actions"
}
