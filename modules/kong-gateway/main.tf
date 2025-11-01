# modules/kong-gateway/main.tf

# Kong ECS Task Definition
resource "aws_ecs_task_definition" "kong_task" {
  family                   = "${var.project_name}-${var.environment}-kong"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.kong_cpu
  memory                   = var.kong_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn           = aws_iam_role.kong_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "kong"
      image     = var.kong_image
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        },
        {
          containerPort = 8443
          hostPort      = 8443
          protocol      = "tcp"
        },
        {
          containerPort = 8001
          hostPort      = 8001
          protocol      = "tcp"
        },
        {
          containerPort = 8444
          hostPort      = 8444
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "KONG_DATABASE"
          value = "off"
        },
        {
          name  = "KONG_PROXY_ACCESS_LOG"
          value = "/dev/stdout"
        },
        {
          name  = "KONG_ADMIN_ACCESS_LOG"
          value = "/dev/stdout"
        },
        {
          name  = "KONG_PROXY_ERROR_LOG"
          value = "/dev/stderr"
        },
        {
          name  = "KONG_ADMIN_ERROR_LOG"
          value = "/dev/stderr"
        },
        {
          name  = "KONG_ADMIN_LISTEN"
          value = "0.0.0.0:8001, 0.0.0.0:8444 ssl"
        },
        {
          name  = "KONG_PROXY_LISTEN"
          value = "0.0.0.0:8000, 0.0.0.0:8443 ssl"
        },
        {
          name  = "KONG_NGINX_WORKER_PROCESSES"
          value = "2"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.kong_logs.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "kong"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "kong health"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 40
      }
    }
  ])

  tags = {
    Name        = "${var.project_name}-${var.environment}-kong-task"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Kong ECS Service
resource "aws_ecs_service" "kong_service" {
  name            = "${var.project_name}-${var.environment}-kong-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.kong_task.arn
  desired_count   = var.kong_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.kong_sg.id]
    subnets         = var.gateway_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.kong_target_group_arn
    container_name   = "kong"
    container_port   = 8000
  }

  # Optional: Enable for blue-green deployments in production
  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-kong-service"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  depends_on = [aws_iam_role_policy_attachment.kong_task_policy]
}

# Kong Security Group
resource "aws_security_group" "kong_sg" {
  name_prefix = "${var.project_name}-${var.environment}-kong-sg-"
  vpc_id      = var.vpc_id

  # Allow HTTP from ALB
  ingress {
    description     = "HTTP from ALB"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  # Allow HTTPS from ALB
  ingress {
    description     = "HTTPS from ALB"
    from_port       = 8443
    to_port         = 8443
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  # Allow Admin API access from within VPC only
  ingress {
    description = "Admin API from VPC"
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # Allow Admin HTTPS from within VPC only
  ingress {
    description = "Admin HTTPS from VPC"
    from_port   = 8444
    to_port     = 8444
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-kong-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# CloudWatch Log Group for Kong
resource "aws_cloudwatch_log_group" "kong_logs" {
  name              = "/ecs/${var.project_name}-${var.environment}-kong"
  retention_in_days = 30

  tags = {
    Name        = "${var.project_name}-${var.environment}-kong-logs"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# IAM Role for Kong Task
resource "aws_iam_role" "kong_task_role" {
  name = "${var.project_name}-${var.environment}-kong-task-role"

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
    Name        = "${var.project_name}-${var.environment}-kong-task-role"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# IAM Policy for Kong Task Role
resource "aws_iam_policy" "kong_task_policy" {
  name        = "${var.project_name}-${var.environment}-kong-task-policy"
  description = "Policy for Kong ECS task"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-kong-task-policy"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "kong_task_policy" {
  role       = aws_iam_role.kong_task_role.name
  policy_arn = aws_iam_policy.kong_task_policy.arn
}

data "aws_region" "current" {}