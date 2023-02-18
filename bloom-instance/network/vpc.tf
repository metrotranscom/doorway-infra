# Not sure if I need this file.
# The VPC acts as our own dedicated slice of the cloud
# It's the root of our network and where most of our resources will reside
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags       = var.tags
}
