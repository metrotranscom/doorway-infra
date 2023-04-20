
variable "zone_map" {
  type        = map(string)
  description = "A map of zone names to IDs"
}

variable "dns_name" {
  type = string

  validation {
    # This is just very basic validation to catch any obvious errors
    condition     = can(regex("^([0-9a-z\\-]+\\.)+[0-9a-z\\-]+$", var.dns_name))
    error_message = "DNS name must be a valid domain"
  }

  description = "The DNS name to find the matching zones for"
}
