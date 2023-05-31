
variable "name_prefix" {
  type        = string
  description = "A prefix to enable resource namespacing"
}

variable "name" {
  type        = string
  description = "The name of this CodeBuild project"
}

# variable "tf_root" {
#   type = object({
#     source = string
#     path = string
#   })
#   description = "The location (source repo and path) to run terraform commands"
# }

variable "policy_arns" {
  type        = set(string)
  description = "A set of policy ARNS to attach to the role assumed by this project"
}

variable "env_vars" {
  type        = map(string)
  description = "Environment variables to set for this build environment"
}

variable "buildspec_path" {
  type        = string
  description = "The path to the buildspec file provided through CodePipeline"
}
