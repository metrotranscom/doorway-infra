
variable "res_acct_id" {
  type        = string
  default     = ""
  description = "The ID of the account where resources will be deployed (default current)"
}

variable "res_acct_part" {
  type        = string
  default     = "aws"
  description = "The partition where the account where resources will be deployed resides (default \"aws\")"
}
