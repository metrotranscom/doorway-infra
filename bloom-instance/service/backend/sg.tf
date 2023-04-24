
# Enable outbound connections from service to DB port
resource "aws_vpc_security_group_egress_rule" "from_alb" {
  security_group_id = module.service.security_group.id

  description = "Allow service ${local.name} to access database"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = var.db.port
  to_port     = var.db.port
  ip_protocol = "tcp"

  tags = var.additional_tags
}

# Enable inbound connections to DB from service
resource "aws_vpc_security_group_ingress_rule" "from_alb" {
  security_group_id = var.db.security_group_id

  description = "Allow service ${local.name} to access database"
  from_port   = var.db.port
  to_port     = var.db.port
  ip_protocol = "tcp"
  #referenced_security_group_id = module.service.security_group.id
  cidr_ipv4 = "0.0.0.0/0"


  tags = var.additional_tags
}
