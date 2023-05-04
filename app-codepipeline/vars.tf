variable "name_prefix" {
  type        = string
  description = "A prefix to be used when creating resources to provide a distinct, yet recognizable name"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name_prefix))
    error_message = "name_prefix can only contain letters, numbers, and hyphens"
  }
}

variable "sdlc_stage" {
  type        = string
  default     = "dev"
  description = "The stage of the software development lifecycle this deployement represents"

  validation {
    condition     = contains(["dev", "test", "qa", "staging", "prod"], var.sdlc_stage)
    error_message = "Valid values for var: sdlc_stage are (dev, test, qa, staging, prod)."
  }
}

variable "ecr_namespace" {
  type        = string
  description = "A project name used as a namespace for the ECR registry. Example <host>/<ecr_namespace>/<image_name>"
  default = ""
  validation {
    condition     = var.ecr_namespace == "" || can(regex("^[[:alnum:]\\-]+$", var.ecr_namespace))
    error_message = "ecr_namespace can only contain letters, numbers, and hyphens"
  }
}

variable "ecr_account_id" {
  type        = string
  description = "an AWS Account ID for the ECR target"
  default     = ""
  validation {
    condition     = var.ecr_account_id == "" || can(regex("^[0-9]+$", var.ecr_account_id))
    error_message = "Expecting all numbers for an AWS Account ID"
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

variable "repo" {
  type = object({
    name=string,
    branch=string
  })
  description = "Full GitHub repo name in the format of organization/repo and the branch the pipeline will watch"
  validation {
    condition     = can(regex("^[^\\/]+\\/[^\\/]+$", var.repo.name)) && can(regex("^.+$", var.repo.branch))
    error_message = "Repo name must be in the format of: `organization/repo' and branch name can't be empty."
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

variable "build_env_vars" {
  type = map(string)
  description = "Map of <env name>: <env value> that is injected as environment variables when building the image"
}
