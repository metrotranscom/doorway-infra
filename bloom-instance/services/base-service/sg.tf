

resource "aws_security_group" "service" {
  name        = local.default_name
  description = "ECS Service ${local.name}"
  vpc_id      = local.vpc_id
}

# Allow outbound HTTP traffic to anywhere
resource "aws_vpc_security_group_egress_rule" "http" {
  security_group_id = aws_security_group.service.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  tags = var.additional_tags
}

# Allow outbound HTTPS traffic to anywhere
resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.service.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  tags = var.additional_tags
}

# Allow the ALB to reach this service
resource "aws_vpc_security_group_ingress_rule" "from_alb" {
  security_group_id = aws_security_group.service.id

  description                  = "Allow HTTP from ALB to service ${local.name}"
  from_port                    = local.port
  to_port                      = local.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.alb_sg_id

  tags = var.additional_tags
}
