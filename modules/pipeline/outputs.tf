
output "arn" {
  value = aws_codepipeline.pipeline.arn
}

output "stages" {
  value = module.stages
}
