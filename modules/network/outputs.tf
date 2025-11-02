# modules/network/outputs.tf

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.luralite_vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.luralite_vpc.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.luralite_igw.id
}

output "availability_zones" {
  description = "List of available availability zones"
  value       = data.aws_availability_zones.available.names
}

output "public_subnet_ids" {
  description = "List of public subnet IDs (for Load Balancers)"
  value       = aws_subnet.public_subnets[*].id
}

output "gateway_subnet_ids" {
  description = "List of gateway subnet IDs (for Kong API Gateway)"
  value       = aws_subnet.gateway_subnets[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs (for internal microservices)"
  value       = aws_subnet.private_subnets[*].id
}


output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public_route_table.id
}

output "gateway_route_table_ids" {
  description = "List of gateway route table IDs"
  value       = aws_route_table.gateway_route_tables[*].id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private_route_table.id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.luralite_nat_gateways[*].id
}

# modules/network/outputs.tf

# ... previous outputs ...

output "vpc_endpoint_security_group_id" {
  description = "ID of the security group for VPC endpoints"
  value       = aws_security_group.vpc_endpoint_sg.id
}

output "s3_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = aws_vpc_endpoint.s3_endpoint.id
}

output "ecr_api_endpoint_id" {
  description = "ID of the ECR API VPC endpoint"
  value       = aws_vpc_endpoint.ecr_api_endpoint.id
}

output "ecr_dkr_endpoint_id" {
  description = "ID of the ECR DKR VPC endpoint"
  value       = aws_vpc_endpoint.ecr_dkr_endpoint.id
}