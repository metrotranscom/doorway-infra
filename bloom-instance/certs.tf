
module "certs" {
  source   = "./cert"
  for_each = { for key, cert in var.certs : key => cert }

  cert = each.value
}
