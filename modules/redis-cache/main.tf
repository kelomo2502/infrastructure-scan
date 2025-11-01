# modules/redis-cache/main.tf

# Elasticache Redis Cluster
resource "aws_elasticache_cluster" "luralite_redis" {
  cluster_id           = "${var.project_name}-${var.environment}-redis"
  engine               = "redis"
  engine_version       = var.redis_version
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = aws_elasticache_parameter_group.luralite_redis_pg.name
  port                 = 6379
  security_group_ids   = [aws_security_group.redis_sg.id]
  subnet_group_name    = aws_elasticache_subnet_group.luralite_redis_sg.name

  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = "06:00-07:00"
  maintenance_window       = "sun:07:00-sun:08:00"

  tags = {
    Name        = "${var.project_name}-${var.environment}-redis"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Elasticache Subnet Group
resource "aws_elasticache_subnet_group" "luralite_redis_sg" {
  name       = "${var.project_name}-${var.environment}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-redis-subnet-group"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Elasticache Parameter Group
resource "aws_elasticache_parameter_group" "luralite_redis_pg" {
  name   = "${var.project_name}-${var.environment}-redis-pg"
  family = var.redis_parameter_family

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  parameter {
    name  = "notify-keyspace-events"
    value = "Kx"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-redis-pg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Redis Security Group
resource "aws_security_group" "redis_sg" {
  name_prefix = "${var.project_name}-${var.environment}-redis-sg-"
  vpc_id      = var.vpc_id

  ingress {
    description = "Redis from ECS services"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-redis-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}