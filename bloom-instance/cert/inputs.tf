
variable "zones" {
  type        = map(string)
  description = "A map of zone names to IDs"
}

variable "cert" {
  type = object({
    domain = string
    #zone      = string
    alt_names = optional(list(string))
  })

  description = "Information about the TLS certificate to create"
}
