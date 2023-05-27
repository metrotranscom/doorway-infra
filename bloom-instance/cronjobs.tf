
module "import_listings" {
  source = "./cronjob/import-listings"

  name_prefix     = local.default_name
  ecs_cluster_arn = aws_ecs_cluster.default.arn
  log_group_name  = local.task_log_group_name

  network = module.network
  db      = module.db

  settings = var.listings_import_task
}
