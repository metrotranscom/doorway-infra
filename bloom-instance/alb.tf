
module "albs" {
  source   = "./alb"
  for_each = { for name, alb in var.albs : name => alb }

  vpc_id     = module.network.vpc.id
  log_bucket = aws_s3_bucket.logging_bucket.bucket

  # Pass in available subnets so the ALB can pick which subnets to deploy into based on subnet group
  # Also used by listener module to allow IPs from subnets in allowed_subnets
  subnets = module.network.subnets

  # Provide a map of managed certificates so the config can refer to them by name rather than ARN
  # The ARN is then resolved by the listener module based on the tls config
  cert_map = { for name, cert in module.certs : name => cert.arn }

  name_prefix    = local.qualified_name_prefix
  name           = each.key
  enable_logging = each.value.enable_logging
  internal       = each.value.internal
  listeners      = each.value.listeners
  subnet_group   = each.value.subnet_group
}
