# modules/rabbitmq/outputs.tf

output "rabbitmq_endpoints" {
  description = "RabbitMQ broker endpoints"
  value       = aws_mq_broker.luralite_rabbitmq.instances
  sensitive   = true
}

output "rabbitmq_amqp_endpoint" {
  description = "RabbitMQ AMQP endpoint"
  value       = aws_mq_broker.luralite_rabbitmq.instances[0].endpoints[0]
  sensitive   = true
}

output "rabbitmq_console_url" {
  description = "RabbitMQ management console URL"
  value       = aws_mq_broker.luralite_rabbitmq.instances[0].console_url
  sensitive   = true
}

output "rabbitmq_username" {
  description = "RabbitMQ username"
  value       = var.rabbitmq_username
}

output "rabbitmq_security_group_id" {
  description = "RabbitMQ security group ID"
  value       = aws_security_group.rabbitmq_sg.id
}