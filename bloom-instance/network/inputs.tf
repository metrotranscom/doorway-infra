
variable "vpc_cidr" {
  type        = string
  description = "Passed through ./vars.tf. The IP addresses to allocate to our VPC"
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to our network resources"
}
