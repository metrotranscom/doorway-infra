variable "project_name" {
  type        = string
  description = "A human-readable name for this project. Can be changed if needed"

  validation {
    condition     = can(regex("^[\\w\\s\\.\\-]+$", var.project_name))
    error_message = "project_name can only contain letters, numbers, spaces, periods, underscores, and hyphens"
  }
}
variable "partners_portal_domain" {
  type        = string
  description = "The domain name of the partner portal."

}
variable "public_portal_domain" {
  type        = string
  description = "The domain name of the public portal."

}
variable "backend_api_domain" {
  type        = string
  description = "The domain name of the API."

}
variable "application_name" {
  type        = string
  description = "The name for the application deployed"

  validation {
    condition     = can(regex("^[\\w\\s\\.\\-]+$", var.application_name))
    error_message = "application_name can only contain letters, numbers, spaces, periods, underscores, and hyphens"
  }
}

variable "project_id" {
  type        = string
  description = "A unique, immutable identifier for this project"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.project_id))
    error_message = "project_id can only contain letters, numbers, and hyphens"
  }
}

# This var is only set on resource tags. Standard tag naming restrictions apply
variable "owner" {
  type        = string
  description = "The owner of the resources created via these templates"

  validation {
    condition     = can(regex("^[\\w\\s\\.\\-\\:\\/\\=\\+@]{1,255}$", var.owner))
    error_message = "owner can only contain letters, numbers, spaces, and these special characters: _ . : / = + - @"
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

variable "environment" {
  type        = string
  default     = "dev"
  description = "The stage of the software development lifecycle this deployement represents"

  validation {
    condition     = can(regex("^[[:alpha:]][[:alnum:]]{0,10}$", var.environment))
    error_message = "environment can only contain letters and numbers, must start with a letter, and must be 10 or fewer characters"
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
variable "cloudfront" {
  type        = any
  default     = null
  description = "The object defining settings for the CloudFront distribution"
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
  # See cronjobs/import-listings/inputs.tf for object structure
  type        = any
  description = "Setting for the \"Import Listings\" scheduled task"
}
