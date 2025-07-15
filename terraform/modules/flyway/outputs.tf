# Flyway Module Outputs

output "ecs_cluster" {
  description = "ECS cluster information"
  value = local.create_ecs_cluster ? {
    id   = aws_ecs_cluster.ecs_cluster[0].id
    arn  = aws_ecs_cluster.ecs_cluster[0].arn
    name = aws_ecs_cluster.ecs_cluster[0].name
  } : null
}

output "ecs_cluster_id" {
  description = "ECS cluster ID used by Flyway"
  value       = local.cluster_id
}
output "flyway_task_definition_arn" {
  description = "ARN of the Flyway task definition"
  value       = var.db_cluster_name != "" ? aws_ecs_task_definition.flyway_task[0].arn : null
}
