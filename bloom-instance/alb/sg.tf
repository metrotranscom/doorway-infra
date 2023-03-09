
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-${var.name}"
  description = "Enable access to ${var.name} ALB"
  vpc_id      = var.vpc_id

  tags = var.additional_tags
}

# Allow outbound TCP traffic to anywhere
resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 1
  to_port     = 65535
  ip_protocol = "tcp"

  tags = var.additional_tags
}

# Create one ingress rule for each listener/port/ip combination
resource "aws_vpc_security_group_ingress_rule" "ingress" {
  for_each = { for pm in local.port_mappings : "${pm.name}-${pm.port}-${pm.cidr}" => pm }

  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = each.value.cidr
  from_port   = each.value.port
  to_port     = each.value.port
  ip_protocol = "tcp"

  tags = var.additional_tags
}
