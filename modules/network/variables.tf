# modules/network/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "The deployment environment"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

# New variables for subnets
variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets (Load Balancers only)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "gateway_subnet_cidrs" {
  description = "List of CIDR blocks for gateway subnets (Kong API Gateway)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets (Internal microservices)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}