
variable "zones" {
  type        = map(string)
  description = "A map of zone names to IDs"
}

variable "cert" {
  type = object({
    domain        = string
    auto_validate = optional(bool, true)
    alt_names     = optional(list(string))
  })

  description = "Information about the TLS certificate to create"
}
