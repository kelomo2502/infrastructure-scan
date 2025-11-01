# modules/kong-gateway/outputs.tf

output "kong_service_name" {
  description = "Name of the Kong ECS service"
  value       = aws_ecs_service.kong_service.name
}

output "kong_task_definition_arn" {
  description = "ARN of the Kong task definition"
  value       = aws_ecs_task_definition.kong_task.arn
}

output "kong_security_group_id" {
  description = "ID of the Kong security group"
  value       = aws_security_group.kong_sg.id
}