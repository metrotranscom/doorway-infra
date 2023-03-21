
variable "cert" {
  type = object({
    domain    = string
    zone      = string
    alt_names = optional(list(string))
  })

  description = "Information about the TLS certificate to create"
}
