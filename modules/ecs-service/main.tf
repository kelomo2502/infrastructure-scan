# modules/ecs-service/main.tf

# ECS Task Definition for a microservice
resource "aws_ecs_task_definition" "microservice_task" {
  family                   = "${var.project_name}-${var.environment}-${var.service_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = aws_iam_role.microservice_task_role.arn

  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = "${var.ecr_repository_url}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = var.environment_variables

      secrets = var.secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.microservice_logs.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = var.service_name
        }
      }

      healthCheck = var.health_check
    }
  ])

  tags = {
    Name        = "${var.project_name}-${var.environment}-${var.service_name}-task"
    Project     = var.project_name
    Environment = var.environment
    Service     = var.service_name
    ManagedBy   = "terraform"
  }
}

# ECS Service
resource "aws_ecs_service" "microservice" {
  name            = "${var.project_name}-${var.environment}-${var.service_name}-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.microservice_task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.microservice_sg.id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  dynamic "load_balancer" {
    for_each = var.target_group_arn != null ? [1] : []
    content {
      target_group_arn = var.target_group_arn
      container_name   = var.service_name
      container_port   = var.container_port
    }
  }

  # Enable deployment circuit breaker
  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  # Service discovery for internal communication
  service_registries {
    registry_arn = aws_service_discovery_service.microservice.arn
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-${var.service_name}-service"
    Project     = var.project_name
    Environment = var.environment
    Service     = var.service_name
    ManagedBy   = "terraform"
  }
}

# CloudMap Service Discovery
resource "aws_service_discovery_service" "microservice" {
  name = var.service_name

  dns_config {
    namespace_id = var.service_discovery_namespace_id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-${var.service_name}-discovery"
    Project     = var.project_name
    Environment = var.environment
    Service     = var.service_name
    ManagedBy   = "terraform"
  }
}

# Microservice Security Group
resource "aws_security_group" "microservice_sg" {
  name_prefix = "${var.project_name}-${var.environment}-${var.service_name}-sg-"
  vpc_id      = var.vpc_id
  description = "Security group for ${var.service_name} microservice in ${var.environment} environment"

  # Allow traffic from Kong API Gateway
  ingress {
    description     = "Traffic from Kong API Gateway"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [var.kong_security_group_id]
  }

  # Allow traffic from other microservices in the same VPC
  ingress {
    description = "Internal service communication"
    from_port   = var.container_port
    to_port     = var.container_port
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
    Name        = "${var.project_name}-${var.environment}-${var.service_name}-sg"
    Project     = var.project_name
    Environment = var.environment
    Service     = var.service_name
    ManagedBy   = "terraform"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "microservice_logs" {
  name              = "/ecs/${var.project_name}-${var.environment}-${var.service_name}"
  retention_in_days = 30

  tags = {
    Name        = "${var.project_name}-${var.environment}-${var.service_name}-logs"
    Project     = var.project_name
    Environment = var.environment
    Service     = var.service_name
    ManagedBy   = "terraform"
  }
}

# IAM Role for Microservice Task
resource "aws_iam_role" "microservice_task_role" {
  name = "${var.project_name}-${var.environment}-${var.service_name}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-${var.service_name}-task-role"
    Project     = var.project_name
    Environment = var.environment
    Service     = var.service_name
    ManagedBy   = "terraform"
  }
}

# Attach AWS managed policies
resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.microservice_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.microservice_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Custom policy only for secrets manager if needed
resource "aws_iam_policy" "secrets_policy" {
  count = length(var.secrets_manager_arns) > 0 ? 1 : 0

  name        = "${var.project_name}-${var.environment}-${var.service_name}-secrets-policy"
  description = "Secrets Manager access for ${var.service_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.secrets_manager_arns
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-${var.service_name}-secrets-policy"
    Project     = var.project_name
    Environment = var.environment
    Service     = var.service_name
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "secrets_policy" {
  count = length(var.secrets_manager_arns) > 0 ? 1 : 0

  role       = aws_iam_role.microservice_task_role.name
  policy_arn = aws_iam_policy.secrets_policy[count.index].arn
}

data "aws_region" "current" {}