
output "arn" {
  value = aws_acm_certificate.cert.arn
}

output "unmatched_validation_records" {
  value = local.unmatched_records
}
