
output "fqdn" {
  value = local.zone_id != null ? aws_route53_record.alias[0].fqdn : null
}
