
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

    # The values for that record
    values = list(string)

    # The TTL for that record (default 60 seconds)
    ttl = optional(number, 60)
  })

  description = "Attributes for the DNS record to create"
}
