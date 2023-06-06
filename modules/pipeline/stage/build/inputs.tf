
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
  default     = 60
  description = "The amount of time to let the build job run before failing"
}

variable "compute_type" {
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
  description = "The size of build instance to use"
}

variable "image" {
  type        = string
  default     = "aws/codebuild/standard:6.0"
  description = "The container image to use for the build job"
}

variable "policy_arns" {
  type        = set(string)
  description = "A set of policy ARNS to attach to the role assumed by this project"
}

variable "env_vars" {
  type        = map(string)
  description = "Environment variables to set for this build environment"
}

variable "buildspec" {
  type = object({
    source = string
    path   = string
  })
  description = "The path to the buildspec file provided through CodePipeline"
}
