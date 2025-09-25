
locals {
  event_maps = {
    action : {
      succeeded : "codepipeline-pipeline-action-execution-succeeded"
      failed : "codepipeline-pipeline-action-execution-failed"
      canceled : "codepipeline-pipeline-action-execution-canceled"
      started : "codepipeline-pipeline-action-execution-started"
    }

    stage : {
      succeeded : "codepipeline-pipeline-stage-execution-succeeded"
      failed : "codepipeline-pipeline-stage-execution-failed"
      canceled : "codepipeline-pipeline-stage-execution-canceled"
      started : "codepipeline-pipeline-stage-execution-started"
      resumed : "codepipeline-pipeline-stage-execution-resumed"
    }

    pipeline : {
      succeeded : "codepipeline-pipeline-pipeline-execution-succeeded"
      failed : "codepipeline-pipeline-pipeline-execution-failed"
      canceled : "codepipeline-pipeline-pipeline-execution-canceled"
      started : "codepipeline-pipeline-pipeline-execution-started"
      resumed : "codepipeline-pipeline-pipeline-execution-resumed"
      superseded : "codepipeline-pipeline-pipeline-execution-superseded"
    }

    approval : {
      succeeded : "codepipeline-pipeline-manual-approval-succeeded"
      failed : "codepipeline-pipeline-manual-approval-failed"
      needed : "codepipeline-pipeline-manual-approval-needed"
    }
  }

  events = concat([for scope, events in var.events : [
    for event in events : local.event_maps[scope][event]
  ]]...)
}

module "rule" {
  source = "../"

  name_prefix  = var.name_prefix
  name         = var.name
  topic_arn    = var.topic_arn
  resource_arn = var.pipeline_arn
  detail       = var.detail
  events       = local.events
}
