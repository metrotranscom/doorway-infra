
# module "nlbs" {
#   source   = "./nlb"
#   for_each = { for name, nlb in var.nlbs : name => nlb }

#   vpc_id     = module.network.vpc.id
#   log_bucket = aws_s3_bucket.logging_bucket.bucket

#   # Pass in available subnets so the ALB can pick which subnets to deploy into based on subnet group
#   # Also used by listener module to allow IPs from subnets in allowed_subnets
#   subnets = module.network.subnets


#   name_prefix     = local.qualified_name_prefix
#   name            = each.key
#   enable_logging  = each.value.enable_logging
#   internal        = each.value.internal
#   listeners       = each.value.listeners
#   subnet_group    = each.value.subnet_group
#   certificate_arn = module.certs[each.value.default_cert].arn
#   alb_arn         = module.albs["api"].alb.arn
# }
