variable "project_name" {
  type        = string
  description = "Name of the project"

  validation {
    condition     = can(regex("^[\\w\\s\\.\\-]+$", var.project_name))
    error_message = "project_name can only contain letters, numbers, spaces, periods, underscores, and hyphens"
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

variable "name_prefix" {
  type        = string
  description = "A prefix to be used when creating resources to provide a distinct, yet recognizable name"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name_prefix))
    error_message = "name_prefix can only contain letters, numbers, and hyphens"
  }
}

variable "team_name" {
  type        = string
  description = "The name of the team that owns this deployment"

  validation {
    condition     = can(regex("^[\\w\\s\\.\\-]+$", var.team_name))
    error_message = "team_name can only contain letters, numbers, spaces, periods, underscores, and hyphens"
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

variable "sdlc_stage" {
  type        = string
  default     = "dev"
  description = "The stage of the software development lifecycle this deployement represents"

  validation {
    condition     = contains(["dev", "test", "qa", "staging", "prod"], var.sdlc_stage)
    error_message = "Valid values for var: sdlc_stage are (dev, test, qa, staging, prod)."
  }
}

variable "subnet_map" {
  type = object({
    public = list(object({
      az   = string
      cidr = string
    }))

    app = list(object({
      az   = string
      cidr = string
    }))

    data = list(object({
      az   = string
      cidr = string
    }))
  })
  description = "The subnets to create in our VPC"
}

variable "vpc_cidr" {
  type        = string
  description = "The IP addresses to allocate to our VPC, e.g. 10.0.0.0/16"
}

variable "use_ngw" {
  type        = bool
  description = "Whether to set up a NAT Gateway in the VPC"
}

variable "public_sites" {
  # See services/public-service/inputs.tf for object structure
  type        = any
  description = "A list of public portal service definitions"
}
