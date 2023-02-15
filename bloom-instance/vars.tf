variable "project_name" {
  type        = string
  description = "Name of the project"

  # add validation rule!
}

variable "application_name" {
  type        = string
  description = "The name for the application deployed"

  # add validation rule!
}

variable "resource_prefix" {
  type        = string
  description = "A prefix to be used when creating resources to provide a distinct, yet recognizable name"

  # add validation rule!
}

variable "team_name" {
  type        = string
  description = "The name of the team that owns this deployment"

  # add validation rule!
}

variable "aws_region" {
  type        = string
  description = "The region to use when deploying regional resources"

  # add validation rule!
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