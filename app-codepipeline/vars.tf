variable "project_id" {
  type        = string
  description = "An identifier to be used when creating resources to provide a distinct, yet recognizable name"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.project_id))
    error_message = "project_id can only contain letters, numbers, and hyphens"
  }
}

variable "aws_region" {
  type        = string
  description = "The region to use when deploying regional resources, for example ECS and ECR"

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
    sources             = any
    stages              = any
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
