
output "cert_validation_records_not_created" {
  value = { for key, cert in module.certs : key => cert.unmatched_validation_records }
}
