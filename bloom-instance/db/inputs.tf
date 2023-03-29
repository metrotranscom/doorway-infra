
variable "name_prefix" {
  type        = string
  description = "The prefix to prepend to resource names"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name_prefix))
    error_message = "name_prefix can only contain letters, numbers, and hyphens"
  }
}

variable "subnet_map" {
  type = map(list(object({
    id     = string
    vpc_id = string
  })))
  description = "A map of the available subnets"
}

variable "settings" {
  type = object({
    db_name                   = string
    type                      = string
    subnet_group              = string
    engine_version            = string
    instance_class            = string
    port                      = optional(number, 5432) # Default to postgres port
    prevent_deletion          = optional(bool, true)   # We usually want to default to preserving the database
    apply_changes_immediately = optional(bool, false)
    username                  = string
    password                  = optional(string)

    maintenance_window = string

    # Only valid for type "rds"
    storage = optional(object({
      min = number
      max = optional(number, 0)
      #encrypt = optional(bool, false)
      }), {
      min = 20
      max = 0
    })

    backups = object({
      retention = number
      window    = string
    })

    # Only valid for type "aurora-serverless"
    serverless_capacity = optional(object({
      min = number
      max = number
    }))
  })

  validation {
    condition     = contains(["rds", "aurora-serverless"], var.settings.type)
    error_message = "type must be either \"rds\" or \"aurora-serverless\""
  }

  validation {
    condition     = !(var.settings.type == "aurora-serverless" && var.settings.serverless_capacity == null)
    error_message = "serverless_capacity is required if type is \"aurora-serverless\""
  }

  validation {
    condition     = var.settings.storage.min >= 20
    error_message = "The minimum amount of database storage that can be allocated is 20 GB"
  }

  validation {
    condition     = can(regex("^(Sun|Mon|Tue|Wed|Thu|Fri|Sat):[0-2][0-9]:[0-5][0-9]\\-(Sun|Mon|Tue|Wed|Thu|Fri|Sat):[0-2][0-9]:[0-5][0-9]$", var.settings.maintenance_window))
    error_message = "maintenance_window must be in the format Day:HH:MM-Day:HH:MM"
  }

  validation {
    condition     = can(regex("^[0-2][0-9]:[0-5][0-9]\\-[0-2][0-9]:[0-5][0-9]$", var.settings.backups.window))
    error_message = "backups.window must be in the format HH:MM-HH:MM"
  }

  description = "Database settings"
}
