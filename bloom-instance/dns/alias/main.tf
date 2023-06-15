
locals {
  # Find any zones that are a valid suffix for the record DNS name
  # The match logic could probably be improved
  filter = { for zone_name, zone_id in var.zones : zone_name => zone_id if endswith(var.record.name, zone_name) }

  # Put the matches into a list of tuples
  # This could be consolidated with the filter step above, but it's kept 
  # separate in case the map above ends up being useful in other ways
  matches = [for name, id in local.filter : id]

  # Return the first (hopefully only) match
  # this should more accurately be the match with the longest zone name 
  # (higher specificity), but it's unlikely that would be a valid use case.
  zone_id = local.matches[0]
}

resource "aws_route53_record" "alias" {
  count = local.zone_id != null ? 1 : 0

  zone_id = local.zone_id
  name    = var.record.name
  type    = var.record.type

  alias {
    name    = var.record.target.dns_name
    zone_id = var.record.target.zone_id

    evaluate_target_health = false
  }
}
