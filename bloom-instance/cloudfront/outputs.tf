
output "domains" {
  value = aws_cloudfront_distribution.main.aliases
}

output "dns_name" {
  value = aws_cloudfront_distribution.main.domain_name
}

output "hosted_zone_id" {
  value = aws_cloudfront_distribution.main.hosted_zone_id
}
