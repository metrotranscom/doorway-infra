
variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The IP addresses to allocate to our VPC"
}

variable "subnet_map" {
  type = object({
    public = list(object({
      az   = string
      cidr = string
    }))

    app = list(object({
      az   = string
      cidr = string
    }))

    data = list(object({
      az   = string
      cidr = string
    }))
  })
  description = "The subnets to create in our VPC"
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "The tags to apply to our network resources. Defaults to aws_default_tags"
}

variable "name_prefix" {
  type        = string
  description = "The prefix to prepend to resource names"
}
