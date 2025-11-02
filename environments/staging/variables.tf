# environments/staging/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "luralite"
}

variable "environment" {
  description = "The deployment environment"
  type        = string
  default     = "staging"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "gateway_subnet_cidrs" {
  description = "List of CIDR blocks for gateway subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "ci_cd_iam_roles" {
  description = "List of IAM role ARNs for CI/CD access to ECR"
  type        = list(string)
  default     = []
}

# DNS and SSL Variables
variable "base_domain_name" {
  description = "Base domain name without subdomain (e.g., luralite-vpn.com)"
  type        = string
  default     = "luralite-vpn.com" # Replace with your actual domain
}

variable "domain_name" {
  description = "Full domain name for this environment (e.g., staging.luralite-vpn.com)"
  type        = string
  default     = "staging.luralite-vpn.com" # Replace with your actual domain
}

variable "subject_alternative_names" {
  description = "List of subject alternative names for the SSL certificate"
  type        = list(string)
  default     = ["*.staging.luralite-vpn.com"] # Replace with your actual domain
}

variable "database_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
}

# Add this variable

variable "rabbitmq_password" {
  description = "Password for RabbitMQ"
  type        = string
  sensitive   = true
}

# Add this variable

variable "database_username" {
  description = "Username for the RDS database"
  type        = string
  default     = "luralite_admin"
}

# Add this variable

variable "rabbitmq_username" {
  description = "Username for RabbitMQ"
  type        = string
  default     = "luralite"
}
variable "test_experiment" {
  description = "Testing PR workflow"
  type        = string
  default     = "pr-test-successful"
}
