
resource "aws_lb" "nlb" {
  name               = "${var.name_prefix}-${var.name}"
  internal           = var.internal
  load_balancer_type = "network"
  security_groups    = [aws_security_group.nlb.id]

  # Note that an NLB requires at least 2 subnets
  subnets = [for subnet in var.subnets[var.subnet_group] : subnet.id]

  enable_deletion_protection = false

  access_logs {
    bucket  = var.log_bucket
    prefix  = local.log_prefix
    enabled = var.enable_logging
  }

  tags = var.additional_tags
}
