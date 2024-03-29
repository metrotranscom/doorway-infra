
output "id" {
  value = aws_cloudfront_cache_policy.policy.id
}
output "default_cache_policy_id" {
  value = aws_cloudfront_cache_policy.default_cache_policy.id
}
