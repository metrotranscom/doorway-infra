
variable "name_prefix" {
  type        = string
  description = "A prefix to enable resource namespacing"
}

variable "name" {
  type        = string
  description = "The name of the environment for this approval"
}

variable "topic_arn" {
  type        = string
  description = "The SNS topic ARN to send notifications to"
}

variable "pipeline_arn" {
  type        = string
  description = "The ARN of the CodePipeline to watch"
}

variable "detail" {
  type        = string
  description = "The level of detail to include in the notification"
}

variable "events" {
  type = object({
    action   = optional(set(string), [])
    stage    = optional(set(string), [])
    pipeline = optional(set(string), [])
    approval = optional(set(string), [])
  })
  description = "The event type to alert on"
}
