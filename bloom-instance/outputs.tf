
output "cert_validation_records_not_created" {
  value = { for key, cert in module.certs : key => cert.unmatched_validation_records }
}

output "urls" {
  value = {
    public   = [for site in module.public_sites : site.url_list]
    partners = module.partner_site.url_list
    backend  = module.backend_api.url_list
  }
}

output "network" {
  value = {
    vpc_id = module.network.vpc.id
    subnets = {
      for name, subnet_group in module.network.subnets : name => [
        for subnet in subnet_group : subnet.id
      ]
    }
  }
}
