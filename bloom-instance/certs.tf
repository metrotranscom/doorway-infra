
module "certs" {
  source   = "./cert"
  for_each = { for cert in var.certs : cert.domain => cert }

  zones = module.dns.zone_map
  cert  = each.value
}
