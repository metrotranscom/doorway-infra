
resource "aws_security_group" "nlb" {
  name        = "${var.name_prefix}-nlb-${var.name}"
  description = "Enable access to ${var.name} NLB"
  vpc_id      = var.vpc_id

  tags = var.additional_tags
}

# Allow outbound TCP traffic to anywhere
# TODO: Change to internal only?
resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.nlb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 1
  to_port     = 65535
  ip_protocol = "tcp"

  tags = var.additional_tags
}