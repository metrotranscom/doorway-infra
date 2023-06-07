
variable "name_prefix" {
  type        = string
  description = "A prefix to enable resource namespacing"
}

variable "name" {
  type        = string
  description = "The name of this CodeBuild project"
}

variable "build_timeout" {
  type        = number
  description = "The amount of time to let the build job run before failing"
}

variable "compute_type" {
  type        = string
  description = "The size of build instance to use"
}

variable "image" {
  type        = string
  description = "The container image to use for the build job"
}

variable "privileged" {
  type        = bool
  description = "Whether the build job needs to be run in privileged mode"
}

variable "policy_arns" {
  type        = set(string)
  description = "A set of policy ARNS to attach to the role assumed by this project"
}

variable "env_vars" {
  type        = map(string)
  description = "Environment variables to set for this build environment"
}

variable "secret_arns" {
  type        = set(string)
  description = "The ARNs of secrets that the build job needs access to"
}

variable "vpc" {
  type = object({
    use             = bool
    vpc_id          = string
    subnets         = set(string)
    security_groups = set(string)
  })

  description = "An optional configuration for the VPC to run the build job in"

  validation {
    condition     = !var.vpc.use || var.vpc.vpc_id != ""
    error_message = "vpc_id cannot be empty if use == true"
  }

  validation {
    condition     = !var.vpc.use || length(var.vpc.subnets) != 0
    error_message = "subnets cannot be empty if use == true"
  }

  validation {
    condition     = !var.vpc.use || length(var.vpc.security_groups) != 0
    error_message = "security_groups cannot be empty if use == true"
  }
}

variable "buildspec" {
  type        = string
  description = "The path to the buildspec file relative to primary source root"
}
