
locals {
  # The prefix to prepend to log entries for this ALB
  log_prefix = "${var.name_prefix}/alb/${var.name}"
}
