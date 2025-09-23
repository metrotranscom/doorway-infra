
module "certs" {
  source   = "./cert"
  for_each = { for name, cert in var.certs : name => cert }

  zones = module.dns.zone_map
  cert  = each.value
}
