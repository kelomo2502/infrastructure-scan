# modules/rabbitmq/main.tf

# MQ RabbitMQ Broker
resource "aws_mq_broker" "luralite_rabbitmq" {
  broker_name    = "${var.project_name}-${var.environment}-rabbitmq"
  engine_type    = "RabbitMQ"
  engine_version = var.rabbitmq_version

  host_instance_type         = var.instance_type
  deployment_mode            = var.deployment_mode
  publicly_accessible        = false
  auto_minor_version_upgrade = true

  security_groups = [aws_security_group.rabbitmq_sg.id]
  subnet_ids      = [var.private_subnet_ids[0]] # Use only the first subnet for SINGLE_INSTANCE

  user {
    username = var.rabbitmq_username
    password = var.rabbitmq_password
  }

  logs {
    general = true
  }

  maintenance_window_start_time {
    day_of_week = "SUNDAY"
    time_of_day = "04:00"
    time_zone   = "UTC"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-rabbitmq"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ... rest of the file remains the same ...
# ... rest of the file remains the same ...
# RabbitMQ Security Group
resource "aws_security_group" "rabbitmq_sg" {
  name_prefix = "${var.project_name}-${var.environment}-rabbitmq-sg-"
  vpc_id      = var.vpc_id

  ingress {
    description = "RabbitMQ AMQP from ECS services"
    from_port   = 5671
    to_port     = 5671
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    description = "RabbitMQ Management from VPC"
    from_port   = 15671
    to_port     = 15671
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
    Name        = "${var.project_name}-${var.environment}-rabbitmq-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}