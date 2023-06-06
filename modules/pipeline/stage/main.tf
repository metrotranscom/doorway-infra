
locals {
  name_prefix = "${var.name_prefix}-${var.name}"

  build_actions_in = { for action in var.actions : action.name => {
    order       = action.order
    policy_arns = action.policy_arns
    env_vars    = action.env_vars
    buildspec   = action.buildspec
  } if action.type == "build" }

  build_actions_out = { for name, build in module.build : name => {
    order        = local.build_actions_in[name].order
    project_name = build.project_name
  } }
}

module "build" {
  source = "./build"

  for_each = local.build_actions_in
  #for_each = { for action in var.actions : action.name => action if action.type == "build" }

  name_prefix = local.name_prefix
  name        = each.key
  buildspec   = each.value.buildspec

  policy_arns = each.value.policy_arns
  env_vars    = each.value.env_vars
}
