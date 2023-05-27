
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

variable "task_role_arn" {
  type        = string
  description = "The IAM role for the task to assume"
}

variable "subnet_groups" {
  type = map(list(object({
    id   = string
    cidr = string
  })))
  description = "A map of the available subnets"
}

variable "task" {
  # See ../ecs/task/inputs.tf for object structure
  type        = any
  description = "The ECS task definition object"
}

variable "network" {
  type = object({
    assign_public_ip = optional(bool, false)
    subnet_group     = string
    security_groups  = list(string)
  })
}

variable "schedule" {
  type = object({
    enabled = optional(bool, true)

    # https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
    expression = string
  })
}

variable "additional_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags to apply to task resources"
}
