
variable "zones" {
  type        = map(string)
  description = "A map of zone names to IDs"
}

variable "record" {
  type = object({
    # The DNS name for the record, ie google.com
    name = string

    # The type of record to create (CNAME, A, TXT, etc)
    type = string

    target = object({
      dns_name = string
      zone_id  = string
    })
  })

  description = "Attributes for the Alias to create"
}
