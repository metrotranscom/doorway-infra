
variable "zone_map" {
  type        = map(string)
  description = "A map of zone names to IDs"
}

variable "dns_name" {
  type        = string
  description = "The DNS name to find the matching zones for"
}
