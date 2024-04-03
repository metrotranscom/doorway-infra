
variable "name" {
  type        = string
  description = "Part of the resource naming convention s/b [app]-[environment]-[stack]-[resource (i.e S3)]-[name i.e logs]"
}
variable "force_destroy" {
  type        = bool
  default     = true
  description = "Delete bucket even if it has data in it. "

}
variable "ignore_public_acls" {
  type        = bool
  default     = true
  description = "Whether Amazon S3 should ignore public ACLs for this bucket. "

}
variable "block_public_policy" {
  type        = bool
  default     = true
  description = "Whether Amazon S3 should block public bucket policies for this bucket. "

}
variable "restrict_public_buckets" {
  type        = bool
  default     = true
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket. "

}
variable "intelligent_tiering_status" {
  type        = string
  default     = "Enabled"
  description = "Whether or not intelligent tiering is enabled. If not you should put your own lifecycle policy on the bucket. "
}
variable "intelligent_tiering_archive_days" {
  type        = number
  default     = 90
  description = "The ammount of days before a file goes into archive status. Defaults to 90"
}
variable "intelligent_tiering_deep_archive_days" {
  type        = number
  default     = 180
  description = "The ammount of days before a file goes into deep archive status. Defaults to 180"
}
