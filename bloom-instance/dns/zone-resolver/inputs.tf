
variable "zones" {
  type        = map(string)
  description = "A map of zone names to IDs"
}

variable "record_name" {
  type        = string
  description = "The DNS name of the record that we want to find the matching zone for"
}
