# environments/staging/main.tf

# Network Module
module "network" {
  source = "../../modules/network"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr_block       = var.vpc_cidr_block
  public_subnet_cidrs  = var.public_subnet_cidrs
  gateway_subnet_cidrs = var.gateway_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# ECR Repositories
module "ecr_identity_svc" {
  source = "../../modules/container-registry"

  project_name = var.project_name
  environment  = var.environment
  service_name = "identity-svc"
}

module "ecr_payment_svc" {
  source = "../../modules/container-registry"

  project_name = var.project_name
  environment  = var.environment
  service_name = "payment-svc"
}

module "ecr_api_gateway" {
  source = "../../modules/container-registry"

  project_name = var.project_name
  environment  = var.environment
  service_name = "api-gateway"
}

# ECS Cluster
module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  project_name = var.project_name
  environment  = var.environment
}

# Route53 Hosted Zone (must come first for SSL certificate)
module "dns" {
  source = "../../modules/dns"

  project_name = var.project_name
  environment  = var.environment
  domain_name  = var.base_domain_name
}

# SSL Certificate (depends on DNS module)
module "ssl_certificate" {
  source = "../../modules/ssl-certificate"

  project_name              = var.project_name
  environment               = var.environment
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  route53_zone_id           = module.dns.hosted_zone_id
}

# Application Load Balancer (depends on SSL certificate)
# Change back to using the module output
# module "load_balancer" {
#   source = "../../modules/load-balancer"

#   project_name        = var.project_name
#   environment         = var.environment
#   vpc_id              = module.network.vpc_id
#   public_subnet_ids   = module.network.public_subnet_ids
#   ssl_certificate_arn = module.ssl_certificate.certificate_arn
# }

# Update the load_balancer module to remove SSL dependency
module "load_balancer" {
  source = "../../modules/load-balancer"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  # Remove ssl_certificate_arn parameter for now
}


# Kong API Gateway
module "kong_gateway" {
  source = "../../modules/kong-gateway"

  project_name                = var.project_name
  environment                 = var.environment
  ecs_cluster_id              = module.ecs_cluster.ecs_cluster_id
  ecs_task_execution_role_arn = module.ecs_cluster.ecs_task_execution_role_arn
  kong_target_group_arn       = module.load_balancer.kong_target_group_arn
  alb_security_group_id       = module.load_balancer.alb_security_group_id
  vpc_id                      = module.network.vpc_id
  vpc_cidr_block              = module.network.vpc_cidr_block
  gateway_subnet_ids          = module.network.gateway_subnet_ids
  kong_desired_count          = 2
}

# Add this after the kong_gateway module

# RDS PostgreSQL Database
module "database" {
  source = "../../modules/database"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.network.vpc_id
  vpc_cidr_block     = module.network.vpc_cidr_block
  private_subnet_ids = module.network.private_subnet_ids

  database_name     = "luralite"
  database_username = "luralite_admin"
  database_password = var.database_password
  instance_class    = "db.t3.micro"
  allocated_storage = 20
}

# Add this after the database module

# Redis Cache
module "redis_cache" {
  source = "../../modules/redis-cache"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.network.vpc_id
  vpc_cidr_block     = module.network.vpc_cidr_block
  private_subnet_ids = module.network.private_subnet_ids

  node_type       = "cache.t3.micro"
  num_cache_nodes = 1
}

# Add this after the redis_cache module

# RabbitMQ Message Queue
module "rabbitmq" {
  source = "../../modules/rabbitmq"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.network.vpc_id
  vpc_cidr_block     = module.network.vpc_cidr_block
  private_subnet_ids = module.network.private_subnet_ids

  rabbitmq_username = "luralite"
  rabbitmq_password = var.rabbitmq_password
}


module "service_discovery" {
  source = "../../modules/service-discovery"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.network.vpc_id
}

# Update the identity_service module to use correct references

# Sample Microservice - Identity Service
# Update the identity_service module with correct RabbitMQ endpoint

# Sample Microservice - Identity Service
# Update the identity_service module with correct RabbitMQ reference

# Sample Microservice - Identity Service
# Update the identity_service module with number values for CPU and memory

# Sample Microservice - Identity Service
# module "identity_service" {
#   source = "../../modules/ecs-service"

#   project_name = var.project_name
#   environment  = var.environment
#   service_name = "identity-svc"

#   ecs_cluster_id              = module.ecs_cluster.ecs_cluster_id
#   ecs_task_execution_role_arn = module.ecs_cluster.ecs_task_execution_role_arn
#   ecr_repository_url          = module.ecr_identity_svc.ecr_repository_url

#   vpc_id              = module.network.vpc_id
#   vpc_cidr_block      = module.network.vpc_cidr_block
#   private_subnet_ids  = module.network.private_subnet_ids
#   kong_security_group_id = module.kong_gateway.kong_security_group_id

#   service_discovery_namespace_id = module.service_discovery.namespace_id

#   container_port = 8080
#   cpu            = 256
#   memory         = 512
#   desired_count  = 2

#   environment_variables = [
#     {
#       name  = "DATABASE_URL"
#       value = "postgresql://${var.database_username}:${var.database_password}@${module.database.rds_endpoint}/${module.database.rds_database_name}"
#     },
#     {
#       name  = "REDIS_URL"
#       value = "redis://${module.redis_cache.redis_endpoint}:${module.redis_cache.redis_port}"
#     },
#     {
#       name  = "RABBITMQ_URL"
#       value = "amqps://${module.rabbitmq.rabbitmq_username}:${var.rabbitmq_password}@${replace(module.rabbitmq.rabbitmq_amqp_endpoint, "amqps://", "")}"
#     },
#     {
#       name  = "NODE_ENV"
#       value = var.environment
#     }
#   ]

#   # Health check specific to identity service
#   health_check = {
#     command     = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
#     interval    = 30
#     timeout     = 5
#     retries     = 3
#     startPeriod = 60
#   }
# }

# Use our ECR repository with the nginx image we pushed
module "identity_service" {
  source = "../../modules/ecs-service"

  project_name = var.project_name
  environment  = var.environment
  service_name = "identity-svc"

  ecs_cluster_id              = module.ecs_cluster.ecs_cluster_id
  ecs_task_execution_role_arn = module.ecs_cluster.ecs_task_execution_role_arn
  ecr_repository_url          = module.ecr_identity_svc.ecr_repository_url
  image_tag                   = "latest" # Use the nginx image we pushed

  vpc_id                 = module.network.vpc_id
  vpc_cidr_block         = module.network.vpc_cidr_block
  private_subnet_ids     = module.network.private_subnet_ids
  kong_security_group_id = module.kong_gateway.kong_security_group_id

  service_discovery_namespace_id = module.service_discovery.namespace_id

  container_port = 80 # nginx uses port 80
  cpu            = 256
  memory         = 512
  desired_count  = 1

  environment_variables = []

  # Simple health check for nginx
  health_check = {
    command     = ["CMD-SHELL", "curl -f http://localhost/ || exit 1"]
    interval    = 30
    timeout     = 5
    retries     = 3
    startPeriod = 30
  }
}
# # DNS Record for ALB (point staging domain to ALB)
resource "aws_route53_record" "staging_alb_alias" {
  zone_id = module.dns.hosted_zone_id
  name    = var.domain_name # e.g., "staging.luralite-vpn.com"
  type    = "A"

  alias {
    name                   = module.load_balancer.alb_dns_name
    zone_id                = module.load_balancer.alb_zone_id
    evaluate_target_health = true
  }

  depends_on = [module.load_balancer]
}