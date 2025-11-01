# modules/container-registry/main.tf

# Create ECR Repository for a microservice
resource "aws_ecr_repository" "microservice_ecr_repo" {
  name                 = "${var.project_name}/${var.environment}/${var.service_name}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-${var.service_name}-ecr"
    Project     = var.project_name
    Environment = var.environment
    Service     = var.service_name
    ManagedBy   = "terraform"
  }
}

# ECR Lifecycle Policy - Fixed priority order
resource "aws_ecr_lifecycle_policy" "microservice_ecr_lifecycle" {
  repository = aws_ecr_repository.microservice_ecr_repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countNumber = 7
          countUnit   = "days"
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2 # Higher number = lower priority
        description  = "Keep last 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ECR Repository Policy - Simplified and fixed
resource "aws_ecr_repository_policy" "microservice_ecr_policy" {
  repository = aws_ecr_repository.microservice_ecr_repo.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECSAccess"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}