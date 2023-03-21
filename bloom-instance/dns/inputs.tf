
variable "dns" {
  type = object({
    # The TTL to use for all records when not specified (default 60 seconds)
    default_ttl = optional(number, 60)

    zones = map(object({
      # The zone ID for this hosted zone
      id = string

      # Records that should be added to this zone beyond what are created automatically
      additional_records = optional(list(object({
        # The DNS name for the record, ie google.com
        name = string

        # The type of record to create (CNAME, A, TXT, etc)
        type = string

        # The values for that record
        values = list(string)

        # The TTL for that record (defaults to default_ttl)
        ttl = optional(number)
      })))
    }))
  })
  description = "Config for managing DNS resources"
}
