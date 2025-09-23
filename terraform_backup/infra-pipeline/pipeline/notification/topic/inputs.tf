
variable "name_prefix" {
  type        = string
  description = "A prefix to enable resource namespacing"
}

variable "name" {
  type        = string
  description = "The name of the environment for this approval"
}

variable "emails" {
  type        = set(string)
  description = "The email addresses to send notifications to"
}
