# modules/database/outputs.tf

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.luralite_postgres.endpoint
}

output "rds_address" {
  description = "RDS instance address"
  value       = aws_db_instance.luralite_postgres.address
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.luralite_postgres.port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.luralite_postgres.db_name
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds_sg.id
}