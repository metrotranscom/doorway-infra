
variable "name_prefix" {
  type        = string
  description = "The prefix to prepend to resource names"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name_prefix))
    error_message = "name_prefix can only contain letters, numbers, and hyphens"
  }
}

variable "db_name" {
  type        = string
  description = "The name of the database to create"
}

variable "security_group_id" {
  type        = string
  description = "The ID of the security group to attach to this database"
}

variable "db_subnet_group_id" {
  type        = string
  description = "The ID of the DB subnet group to attach to this database"
}

variable "engine_version" {
  type        = string
  description = "The version of Postgres to use"
}

variable "port" {
  type        = number
  default     = 5432
  description = "The port to listen on"
}

variable "instance_class" {
  type        = string
  description = "The class of RDS instance to use"
}

variable "min_storage" {
  type        = number
  description = "The amount of storage to start with"
}

variable "max_storage" {
  type        = number
  default     = null
  description = "The maximum amount of storage to allocate up to as data grows"
}

variable "backup_retention" {
  type        = number
  default     = 30
  description = "The number of days to keep backups"
}

variable "backup_window" {
  type        = string
  default     = "00:00-01:00"
  description = "The window of time in which to take backups (format: \"HH:MM-HH:MM\")"
}

variable "username" {
  type        = string
  description = "The username of the default user to create"
}

variable "prevent_deletion" {
  type        = bool
  default     = true
  description = "Whether to prevent deletion of this database"
}
