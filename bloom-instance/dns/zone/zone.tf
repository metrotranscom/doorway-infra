
resource "aws_route53_zone" "zone" {
  count = local.create_zone ? 1 : 0
  name  = var.name

  tags = merge(
    var.additional_tags,
    {
      # So it's easier to distinguish in the console since we are mixing managed and unmanaged
      ManagedByTerraform = "true"
    }
  )
}
