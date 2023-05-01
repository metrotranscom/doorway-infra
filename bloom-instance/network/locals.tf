
locals {
  default_name = "${var.name_prefix}:${var.name}"

  # Get a list of all cases where a group needs an NGW
  need_ngw = [for group in var.subnet_groups : group.use_ngw]

  # If any of them do need one, make sure to create it
  create_ngw = contains(local.need_ngw, true)
  ngw_count  = local.create_ngw ? 1 : 0

  # Validation enforces that there must be one public subnet group
  # Store the id for that group here
  public_subnet_group_id = coalesce([for id, group in var.subnet_groups : id if group.is_public == true]...)

  # and a reference to that group here
  public_subnet_group = var.subnet_groups[local.public_subnet_group_id]

  # The rest of the groups (all private) go here
  private_subnet_groups = { for id, group in var.subnet_groups : id => group if group.is_public != true }

  # Take the default set of tags and add a Name tag.
  # Not all resources use the Name tag, but this makes it easier for the ones that do
  tags_with_name = merge(
    tomap({
      Name = local.default_name,
    }),
    var.additional_tags,
  )
}
