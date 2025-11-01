# modules/rabbitmq/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "The deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "rabbitmq_version" {
  description = "RabbitMQ version"
  type        = string
  default     = "3.13"  # Updated to valid AWS RabbitMQ version
}

variable "instance_type" {
  description = "RabbitMQ instance type"
  type        = string
  default     = "mq.t3.micro"
}

variable "deployment_mode" {
  description = "RabbitMQ deployment mode"
  type        = string
  default     = "SINGLE_INSTANCE"
}

variable "rabbitmq_username" {
  description = "RabbitMQ username"
  type        = string
  default     = "luralite"
}

variable "rabbitmq_password" {
  description = "RabbitMQ password"
  type        = string
  sensitive   = true
}