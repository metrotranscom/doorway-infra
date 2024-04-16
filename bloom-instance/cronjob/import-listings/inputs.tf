
variable "name_prefix" {
  type        = string
  description = "The prefix to prepend to resource names"

  validation {
    condition     = can(regex("^[[:alnum:]\\-]+$", var.name_prefix))
    error_message = "name_prefix can only contain letters, numbers, and hyphens"
  }
}

variable "ecs_cluster_arn" {
  type        = string
  description = "The ECS cluster to run this task in"
}

variable "log_group_name" {
  type        = string
  description = "The name of the CloudWatch Logs log group to use"
}

# This should match the outputs needed from the network module
variable "network" {
  type = object({
    # VPC object
    vpc = object({
      id = string
    })
    # Map of subnet groups
    subnets = map(list(object({
      id   = string
      cidr = string
    })))
  })

  description = "Outputs from the network module"
}

# This should match the outputs needed from the db module
variable "db" {
  type = object({
    secret_arn = string
    port       = number
  })

  description = "Outputs from the database module"
}

variable "settings" {
  type = object({
    image        = string
    enabled      = optional(bool, true)
    schedule     = string
    subnet_group = string
    env_vars     = map(string)
  })
  description = "Settings for the import listings cronjob"
}
