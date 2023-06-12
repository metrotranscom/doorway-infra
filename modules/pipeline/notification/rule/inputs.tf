
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

variable "resource_arn" {
  type        = string
  description = "The ARN of the CodePipeline to watch"
}

variable "detail" {
  type        = string
  default     = "BASIC"
  description = "The level of detail to include in the notification"

  validation {
    condition     = contains(["BASIC", "FULL"], var.detail)
    error_message = "Valid values for var.detail are (BASIC, FULL)"
  }
}

variable "events" {
  type        = set(string)
  description = "The event type to alert on"
}
