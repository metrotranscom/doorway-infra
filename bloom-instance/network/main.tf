
data "aws_default_tags" "current" {}

locals {
  tags = var.tags != null ? var.tags : data.aws_default_tags.current.tags

  # Take the default set of tags and add a Name tag.
  # Not all resources use the Name tag, but this makes it easier for the ones that do
  tags_with_name = merge(
    tomap({
      Name = var.name_prefix,
    }),
    data.aws_default_tags.current.tags,
  )
}
