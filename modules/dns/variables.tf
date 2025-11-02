# modules/dns/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "The deployment environment"
  type        = string
}

variable "domain_name" {
  description = "Base domain name (e.g., luralite-vpn.com)"
  type        = string
}