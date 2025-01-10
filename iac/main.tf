provider "aws" {
  region = var.aws_region 
}

module "vpc" {
  source = "./modules/vpc"
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
  subnets = var.subnets
}

module "alb" {
  source = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.subnet_ids
  load_balancer_name = "main-load-balancer"
}

module "ecs" {
  source = "./modules/ecs"
  cluster_name = "ecs-cluster"
  task_definitions = var.task_definitions
  services = [
    for service in var.services : {
      name             = service.name
      desired_count    = service.desired_count
      target_group_arn = service.name == "request-validator-service" ? module.alb.target_group_arn : ""
      container_name   = service.container_name
      container_port   = service.container_port
    }
    ]
  vpc_subnet_ids = module.vpc.subnet_ids
}

# Validated requests SQS Queue
resource "aws_sqs_queue" "email_queue" {
  name = "email-processing-queue"
}

# S3 Bucket (message uploader service uploads data here)
resource "aws_s3_bucket" "email_storage" {
  bucket = "email-storage-bucket-unique-id"  # Ensure the bucket name is globally unique
}
