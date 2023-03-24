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

variable "dns" {
  type = any
  /*
  type = object({
    zones = map(object({
      # If this zone already exists and shouldn't be created, add the zone ID here
      zone_id = optional(string)

      # Records that should be added to this zone beyond what are created automatically
      #additional_records = optional(any)
    }))
  })
  */
  description = "Settings for managing DNS zones and records"
}

variable "albs" {
  type = map(object({
    # See alb/inputs.tf for more info
    subnet_group   = string
    enable_logging = optional(bool, true)
    internal       = optional(bool)

    # See alb/listeners/inputs.tf for more info
    listeners = map(object({
      port           = number
      default_action = optional(string)

      allowed_ips     = optional(list(string))
      allowed_subnets = optional(list(string))

      tls = optional(any)
    }))
  }))
  description = "Settings for managing ALBs"
}

variable "public_sites" {
  # See services/base-service/inputs.tf for object structure
  type        = any
  description = "A list of public portal service definitions"
}

variable "partner_site" {
  # See services/base-service/inputs.tf for object structure
  type        = any
  description = "A service definition for the partner site"
}
