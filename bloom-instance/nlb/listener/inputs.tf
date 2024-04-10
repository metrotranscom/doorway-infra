
variable "subnets" {
  type = map(list(object({
    id   = string
    cidr = string
  })))
  description = "A map of available subnets"
}



variable "nlb_arn" {
  type        = string
  description = "The NLB to attach the listener to"
}

variable "security_group_id" {
  type        = string
  description = "The Security Group to attach ingress rules to"
}




variable "allowed_ips" {
  type        = list(string)
  description = "CIDR blocks to allow access from"
}

variable "allowed_subnets" {
  type        = list(string)
  description = "Subnet groups to allow access from"
}

variable "additional_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags to apply to the listener"
}
variable "certificate_arn" {
  type        = string
  description = "ARN to the primary cert for TLS"
}
variable "target_group_arn" {
  type        = string
  description = "The target group of the API ALB"
}
