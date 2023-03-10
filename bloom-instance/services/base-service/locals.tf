
data "aws_subnet" "first" {
  id = var.subnet_ids[0]
}

locals {
  # This saves us an input var
  vpc_id = data.aws_subnet.first.vpc_id
}
