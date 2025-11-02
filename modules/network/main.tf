# modules/network/main.tf

# Data source: Available Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Data source: Current AWS Region
data "aws_region" "current" {}

# First Resource: VPC
resource "aws_vpc" "luralite_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Second Resource: Internet Gateway
resource "aws_internet_gateway" "luralite_igw" {
  vpc_id = aws_vpc.luralite_vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Third Resource: Public Subnets (for Load Balancers)
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.luralite_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false # No public IPs for ALB subnets

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Tier        = "public"
    Use         = "load-balancers"
  }
}

# Fourth Resource: Gateway Subnets (for Kong API Gateway)
resource "aws_subnet" "gateway_subnets" {
  count             = length(var.gateway_subnet_cidrs)
  vpc_id            = aws_vpc.luralite_vpc.id
  cidr_block        = var.gateway_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "${var.project_name}-${var.environment}-gateway-subnet-${count.index + 1}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Tier        = "gateway"
    Use         = "kong-gateway"
  }
}

# Fifth Resource: Private Subnets (for internal microservices)
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.luralite_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-subnet-${count.index + 1}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Tier        = "private"
    Use         = "microservices"
  }
}

# modules/network/main.tf

# ... previous resources (VPC, IGW, subnets) ...

# Sixth Resource: Public Route Table (for Load Balancer subnets)
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.luralite_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.luralite_igw.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Tier        = "public"
  }
}

# Seventh Resource: Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_subnet_associations" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Eighth Resource: NAT Gateway EIPs
resource "aws_eip" "nat_gateway_eips" {
  count  = var.environment == "production" ? length(aws_subnet.public_subnets) : 1
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat-eip-${count.index + 1}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Ninth Resource: NAT Gateways (in public subnets for Kong gateway outbound traffic)
resource "aws_nat_gateway" "luralite_nat_gateways" {
  count         = var.environment == "production" ? length(aws_subnet.public_subnets) : 1
  allocation_id = aws_eip.nat_gateway_eips[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat-gateway-${count.index + 1}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  depends_on = [aws_internet_gateway.luralite_igw]
}

# Tenth Resource: Gateway Route Tables (for Kong subnets - outbound via NAT)
resource "aws_route_table" "gateway_route_tables" {
  count  = length(aws_nat_gateway.luralite_nat_gateways)
  vpc_id = aws_vpc.luralite_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.luralite_nat_gateways[count.index].id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-gateway-rt-${count.index + 1}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Tier        = "gateway"
  }
}

# Eleventh Resource: Associate Gateway Subnets with Gateway Route Tables
resource "aws_route_table_association" "gateway_subnet_associations" {
  count          = length(aws_subnet.gateway_subnets)
  subnet_id      = aws_subnet.gateway_subnets[count.index].id
  route_table_id = aws_route_table.gateway_route_tables[count.index % length(aws_route_table.gateway_route_tables)].id
}

# Twelfth Resource: Private Route Table (for internal services - no internet)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.luralite_vpc.id

  # No internet route - these are truly private subnets
  # Internal routing only within VPC

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-rt"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Tier        = "private"
  }
}

# Thirteenth Resource: Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private_subnet_associations" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

# modules/network/main.tf

# ... previous resources (VPC, IGW, subnets, route tables) ...

# Fourteenth Resource: Security Group for VPC Endpoints
resource "aws_security_group" "vpc_endpoint_sg" {
  name_prefix = "${var.project_name}-${var.environment}-vpce-sg-"
  vpc_id      = aws_vpc.luralite_vpc.id
  description = "Security group for VPC endpoints in ${var.environment} environment" 

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.luralite_vpc.cidr_block]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpce-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Fifteenth Resource: S3 Gateway Endpoint (no charges)
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = aws_vpc.luralite_vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  # Associate with private route tables only (not gateway subnets)
  route_table_ids = [aws_route_table.private_route_table.id]

  tags = {
    Name        = "${var.project_name}-${var.environment}-s3-endpoint"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Sixteenth Resource: ECR API Interface Endpoint (for Docker API calls)
resource "aws_vpc_endpoint" "ecr_api_endpoint" {
  vpc_id              = aws_vpc.luralite_vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private_subnets[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecr-api-endpoint"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Seventeenth Resource: ECR DKR Interface Endpoint (for Docker registry)
resource "aws_vpc_endpoint" "ecr_dkr_endpoint" {
  vpc_id              = aws_vpc.luralite_vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private_subnets[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecr-dkr-endpoint"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Eighteenth Resource: CloudWatch Logs Endpoint
resource "aws_vpc_endpoint" "cloudwatch_logs_endpoint" {
  vpc_id              = aws_vpc.luralite_vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private_subnets[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]

  tags = {
    Name        = "${var.project_name}-${var.environment}-logs-endpoint"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Nineteenth Resource: Secrets Manager Endpoint
resource "aws_vpc_endpoint" "secrets_manager_endpoint" {
  vpc_id              = aws_vpc.luralite_vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private_subnets[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]

  tags = {
    Name        = "${var.project_name}-${var.environment}-secrets-endpoint"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}