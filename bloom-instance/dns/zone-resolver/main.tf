
# This module doesn't create any resources.  All it does is provide a simple, 
# repeatable means for determining which zone ID to use for applying DNS records

locals {
  # Find any zones that are a valid suffix for the record DNS name
  # The match logic could probably be improved
  filter = { for zone_name, zone_id in var.zone_map : zone_name => zone_id if endswith(var.dns_name, zone_name) }

  # Put the matches into a list of objects
  # This could be consolidated with the filter step above, but it's kept 
  # separate in case the map above ends up being useful in other ways
  matches = { for name, id in local.filter : name => {
    name = name
    id   = id
  } }

  # Get a list of all zone names
  domains = keys(local.filter)

  # Create a new map with the lengths of each domain as the key
  # It isn't possible to have conflicting names with the same length
  # Pad the length to 3 places for reliable sorting
  by_length = { for name in local.domains : format("%03d", length(name)) => name }

  # Get the distinct lengths
  lengths = keys(local.by_length)

  # Sort the lengths from shortest to longest
  sort_lengths = sort(local.lengths)

  # Reverse so that the first value is the longest length
  reverse_lengths = reverse(local.sort_lengths)

  # The longest zone/domain name
  longest = length(local.reverse_lengths) > 0 ? local.by_length[local.reverse_lengths[0]] : null

  # The match, if any, is the zone with the longest matching suffix (ie highest specificity)
  match = local.longest != null ? local.matches[local.longest] : null
}
