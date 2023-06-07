
locals {
  name_prefix = "${var.name_prefix}-${var.name}"

  build_actions_out = { for action in var.build_actions : action.name => {
    order        = action.order
    label        = action.label == null ? action.name : action.label
    project_name = module.build[action.name].project_name
  } }

  approval_actions_out = { for action in var.approval_actions : action.name => {
    order     = action.order
    label     = action.label == null ? action.name : action.label
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
  privileged    = each.value.privileged

  vpc = {
    # Whatever the "use" value is on the action is what we pass in
    use = each.value.vpc.use,
    # Use the action's vpc_id if set, otherwise use the default
    vpc_id = each.value.vpc.vpc_id != "" ? each.value.vpc.vpc_id : var.default_network.vpc_id,
    # Use the action's subnets if not empty, otherwise use the default
    subnets = (
      length(each.value.vpc.subnets) != 0
      ? each.value.vpc.subnets
      : var.default_network.subnets
    ),
    # Use the action's security groups if not empty, otherwise use the default
    security_groups = (
      length(each.value.vpc.security_groups) != 0
      ? each.value.vpc.security_groups
      : var.default_network.security_groups
    )
  }

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
