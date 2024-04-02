
variable "zones" {
  type        = map(string)
  description = "A map of zone names to IDs"
}
variable "record_name" {
  type        = string
  description = "the host name for the DNS entry"

}
variable "record_type" {
  type        = string
  default     = "A"
  description = "DNS Record Type"

}
variable "target_name" {
  type    = string
  default = "The target endpoint the DNS entry points to"

}
variable "zone_id" {
  type        = string
  description = "AWS zone of the endpoint"

}
