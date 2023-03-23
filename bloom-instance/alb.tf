
module "albs" {
  source   = "./alb"
  for_each = { for name, alb in var.albs : name => alb }

  vpc_id     = module.network.vpc.id
  log_bucket = aws_s3_bucket.logging_bucket.bucket
  #subnet_ids = [for subnet in module.network.subnets[each.value.subnet_group] : subnet.id]
  # Pass in available subnets so the ALB can pick which subnets to deploy into based on subnet group
  # Also used by listener module to allow IPs from subnets in allowed_subnets
  subnets = module.network.subnets

  name_prefix    = local.default_name
  name           = each.key
  enable_logging = each.value.enable_logging
  internal       = each.value.internal
  listeners      = each.value.listeners
  subnet_group   = each.value.subnet_group

  /*
  listeners = {
    public = {
      port        = 80
      use_tls     = false
      allowed_ips = ["0.0.0.0/0"]
    }

    # internal is here just to provide an easy path forward if we want an internal route to services
    internal = {
      port        = 8080
      use_tls     = false
      allowed_ips = [for subnet in module.network.subnets.app : subnet.cidr_block]
    }
  }
  */
}
