output "bucket" {
    value = aws_s3_bucket.s3_bucket
}

output "encryption_key_arn" {
    value = module.kms.key_arn
  
}