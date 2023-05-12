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

variable "network" {
  type = object({
    vpc_cidr = string

    # See ./network/inputs.tf for object structure
    subnet_groups = any
  })
}

variable "dns" {
  type        = any
  description = "Settings for managing DNS zones and records"
}

variable "database" {
  # See ./database/inputs.tf for object structure
  type        = any
  description = "Database settings"
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
      default_action = optional(string, "404")

      allowed_ips     = optional(list(string))
      allowed_subnets = optional(list(string))

      tls = optional(object({
        enable           = optional(bool, true)
        default_cert     = string
        additional_certs = optional(list(string))
        }), {
        enable           = false
        default_cert     = null
        additional_certs = []
      })
    }))
  }))
  description = "Settings for managing ALBs"
}

variable "public_sites" {
  # See service/inputs.tf for object structure
  type        = any
  description = "A list of public portal service definitions"
}

variable "partner_site" {
  # See service/inputs.tf for object structure
  type        = any
  description = "A service definition for the partner site"
}

variable "backend_api" {
  # See service/inputs.tf for object structure
  type        = any
  description = "A service definition for the backend API"
}

variable "certs" {
  # Keep a well-defined type here to avoid input validation issues with "any"
  type = map(object({
    domain        = string
    auto_validate = optional(bool)
    alt_names     = optional(list(string))
  }))
  description = "The certificates to use"
}

variable "listings_import_task" {
  type = object({
    # See ecs/task/inputs.tf for object structure
    task = any
    # See cronjob/inputs.tf for object structure
    schedule     = any
    subnet_group = string
  })
}
