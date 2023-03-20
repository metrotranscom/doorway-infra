
# This module doesn't create any resources.  All it does is provide a simple, 
# repeatable means for determining which zone ID to use for applying DNS records

locals {
  # Find any zones that are a valid suffix for the record DNS name
  # The match logic could probably be improved
  filter = { for zone_name, zone_id in var.zones : zone_name => zone_id if endswith(var.record_name, zone_name) }

  # Put the matches into a list of tuples
  # This could be consolidated with the filter step above, but it's kept 
  # separate in case the map above ends up being useful in other ways
  matches = [for name, id in local.filter : id]

  # Return the first (hopefully only) match
  # this should more accurately be the match with the longest zone name 
  # (higher specificity), but it's unlikely that would be a valid use case.
  match = local.matches[0]
}
