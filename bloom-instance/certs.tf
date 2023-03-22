
module "certs" {
  source   = "./cert"
  for_each = { for key, cert in var.certs : key => cert }

  zones = module.dns.zone_map
  cert  = each.value
}
