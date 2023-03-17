
variable "name" {
  type        = string
  description = "The name of this zone"

  validation {
    condition     = can(regex("^[[:alnum:]\\.]+$", var.name))
    error_message = "zone_name can only contain letters, numbers, and dots"
  }
}

variable "zone_id" {
  type        = string
  default     = null
  description = "(Optional) The ID of the zone to add records to if it already exists"
}

variable "additional_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags to apply to ALB resources"
}
