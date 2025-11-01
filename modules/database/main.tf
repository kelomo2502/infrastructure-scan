# modules/database/main.tf

# RDS PostgreSQL Database
resource "aws_db_instance" "luralite_postgres" {
  identifier = "${var.project_name}-${var.environment}-postgres"

  engine               = "postgres"
  engine_version       = var.postgres_version 
  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
  storage_type         = "gp3"
  storage_encrypted    = true
  kms_key_id          = var.kms_key_id

  db_name  = var.database_name
  username = var.database_username
  password = var.database_password
  port     = 5432

  multi_az               = var.environment == "production" ? true : false
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.luralite_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  auto_minor_version_upgrade = true
  deletion_protection        = var.environment == "production" ? true : false
  skip_final_snapshot        = var.environment == "production" ? false : true
  final_snapshot_identifier  = var.environment == "production" ? "${var.project_name}-${var.environment}-final-snapshot" : null

  apply_immediately = var.apply_immediately

  tags = {
    Name        = "${var.project_name}-${var.environment}-postgres"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "luralite_db_subnet_group" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-subnet-group"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name_prefix = "${var.project_name}-${var.environment}-rds-sg-"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from ECS services"
    from_port   = 5432
    to_port     = 5432
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
    Name        = "${var.project_name}-${var.environment}-rds-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}