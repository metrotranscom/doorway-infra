
locals {
  # The prefix to prepend to log entries for this NLB
  log_prefix = "${var.name_prefix}/nlb/${var.name}"
}
