
variable "name_prefix" {
  type        = string
  description = "A prefix to enable resource namespacing"
}

variable "name" {
  type        = string
  description = "The name of this CodeBuild project"
}

variable "policy_arns" {
  type        = set(string)
  description = "A set of policy ARNS to attach to the role assumed by this project"
}

variable "env_vars" {
  type = map(string)
  description = "Environment variables to set for this build environment"
}
