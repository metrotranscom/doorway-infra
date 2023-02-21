# The VPC acts as our own dedicated slice of the cloud
# It's the root of our network and where most of our resources will reside
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags       = local.default_tags_with_name
}

# The Internet Gateway (IGW) is what enables bidirectional communication
# in our public subnet.  It's what makes the public subnet "public"
resource "aws_internet_gateway" "igw" {
  # Note that the IGW references the VPC we created above
  vpc_id = aws_vpc.vpc.id
  tags   = local.default_tags_with_name
}
