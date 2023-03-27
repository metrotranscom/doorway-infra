
variable "name_prefix" {
  type        = string
  description = "The prefix to prepend to resource names"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name_prefix))
    error_message = "name_prefix can only contain letters, numbers, and hyphens"
  }
}

# variable "subnet_groups" {
#   type        = any
#   description = "A map of all subnet groups created by the network module"
# }

variable "subnet_ids" {
  type        = list(string)
  description = "The subnets to deploy the database into"
}

variable "settings" {
  type = object({
    db_name          = string
    type             = string
    subnet_group     = string
    engine_version   = string
    instance_class   = string
    port             = optional(number, 5432) # Default to postgres port
    prevent_deletion = optional(bool, true)   # We usually want to default to preserving the database
    username         = string

    storage = object({
      min = number
      max = optional(number, 0)
      #encrypt = optional(bool, false)
    })

    backups = object({
      retention = number
      window    = string
    })
  })

  validation {
    condition     = contains(["rds", "aurora-serverless"], var.settings.type)
    error_message = "type must be either \"rds\" or \"aurora-serverless\""
  }

  description = "Database settings"
}
