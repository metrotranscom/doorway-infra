variable "name_prefix" {
  type        = string
  description = "A prefix to be used when creating resources to provide a distinct, yet recognizable name"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name_prefix))
    error_message = "name_prefix can only contain letters, numbers, and hyphens"
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

variable "repo_connection_arn" {
  type        = string
  description = "ARN of the AWS codestar connection to use to access the repo."
  validation {
    condition     = can(regex("^arn:aws:codestar-connections:\\w+(?:-\\w+)+:\\d{12}:connection\\/[A-Za-z0-9]+(?:-[A-Za-z0-9]+)+$", var.repo_connection_arn))
    error_message = "Invalid AWS codestar connection ARN"
  }
  # "doorway-github-connection" which has been auhtorized for metrotranscom/doorway and metrotranscom/doorway-infra
  default = "arn:aws:codestar-connections:us-east-2:364076391763:connection/ebc8d365-5968-4497-8d4d-d2a4f06be1c4"
}

variable "repo_name" {
  type        = string
  description = "Full GitHub repo name in the format of organization/repo"
  validation {
    # Not comprehensive. Only checks there's a slash, and there's 1+ character before the slash and after the slash
    condition     = can(regex("^[^\\/]+\\/[^\\/]+$", var.repo_name))
    error_message = "Repo name must be in the format of: `organization/repo'. "
  }
}

variable "repo_branch_name" {
  type        = string
  description = "The Branch name in the repo that the pipeline shoulde watch"
  validation {
    # Not comprehsnsive. Only checks it's non empty.
    condition     = can(regex("^.+$", var.repo_branch_name))
    error_message = "Branch name can't be empty."
  }
  default = "main"
}
