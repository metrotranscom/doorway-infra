
output "cert_validation_records_not_created" {
  value = { for key, cert in module.certs : key => cert.unmatched_validation_records }
}

output "public_site_urls" {
  value = [for site in module.public_sites : site.urls_by_listener]
}

output "partner_site_urls" {
  value = module.partner_site.urls_by_listener
}

output "backend_api_urls" {
  value = module.backend_api.urls_by_listener
}
