
# Subnet Group creation will fail if the RDS service linked role has not been created

# Check to see if it exists
data "aws_iam_role" "rds_service" {
  name = "AWSServiceRoleForRDS"
}

# Create it if not
resource "aws_iam_service_linked_role" "rds" {
  count = data.aws_iam_role.rds_service.id == null ? 1 : 0

  aws_service_name = "rds.amazonaws.com"

  # Don't try to delete it
  lifecycle {
    prevent_destroy = true
  }
}
