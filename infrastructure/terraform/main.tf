terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC and Networking
module "vpc" {
  source = "./modules/vpc"
  
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  azs         = var.availability_zones
}

# ECR Repository
module "ecr" {
  source = "./modules/ecr"
  
  repository_name = var.ecr_repository_name
  environment     = var.environment
}

# ECS Cluster and Service
module "ecs" {
  source = "./modules/ecs"
  
  environment           = var.environment
  vpc_id               = module.vpc.vpc_id
  private_subnets      = module.vpc.private_subnets
  public_subnets       = module.vpc.public_subnets
  ecr_repository_url   = module.ecr.repository_url
  app_name             = var.app_name
  app_port             = var.app_port
  app_count            = var.app_count
  health_check_path    = var.health_check_path
  target_group_arn     = module.alb.target_group_arn
  alb_security_group_id = module.alb.alb_security_group_id
  alb_listener_arn     = module.alb.listener_arn
  depends_on           = [module.vpc, module.ecr, module.alb]
}

# Application Load Balancer
module "alb" {
  source = "./modules/alb"
  
  environment      = var.environment
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  app_name        = var.app_name
  app_port        = var.app_port
  health_check_path = var.health_check_path
  depends_on      = [module.vpc]
}

# CloudWatch Logs
module "cloudwatch" {
  source = "./modules/cloudwatch"
  
  environment = var.environment
  app_name    = var.app_name
}

# IAM Roles
module "iam" {
  source = "./modules/iam"
  
  environment = var.environment
  app_name    = var.app_name
} 