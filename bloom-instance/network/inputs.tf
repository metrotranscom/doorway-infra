variable "subnet_map" {
  type        = object({
    public = list(object({
      az   = string
      cidr = string
    }))

    backend = list(object({
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