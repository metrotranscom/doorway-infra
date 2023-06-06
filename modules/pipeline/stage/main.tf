
locals {
  name_prefix = "${var.name_prefix}-${var.name}"

  # build_actions_in = { for action in var.actions : action.name => {
  #   order       = action.order
  #   policy_arns = action.policy_arns
  #   env_vars    = action.env_vars
  #   buildspec   = action.buildspec
  # } if action.type == "build" }

  build_actions_out = { for action in var.build_actions : action.name => {
    order        = action.order
    project_name = module.build[action.name].project_name
  } }

  approval_actions_out = { for action in var.approval_actions : action.name => {
    order     = action.order
    topic_arn = var.notification_topics[action.topic].topic_arn
  } }
}

module "build" {
  source = "./build"

  for_each = { for action in var.build_actions : action.name => action }
  #for_each = { for action in var.actions : action.name => action if action.type == "build" }

  name_prefix   = local.name_prefix
  name          = each.key
  buildspec     = each.value.buildspec
  compute_type  = each.value.compute_type
  image         = each.value.image
  build_timeout = each.value.build_timeout

  # Add stage-level policies to the build-level policies
  policy_arns = setunion(
    each.value.policy_arns,
    var.build_policy_arns
  )

  # Add stage-level env vars to build-level env vars
  # Build-level goes last to overwrite stage-level
  env_vars = merge(
    var.build_env_vars,
    each.value.env_vars
  )
}
