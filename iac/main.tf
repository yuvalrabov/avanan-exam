provider "aws" {
  region = "eu-north-1" 
}

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Subnet in AZ 1 for the microservices
resource "aws_subnet" "subnet_az1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-az1"
  }
}

# Subnet in az 2 for the microservices
resource "aws_subnet" "subnet_az2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-north-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-az2"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-route-table"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.main_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_igw.id
}

resource "aws_route_table_association" "subnet_az1_association" {
  subnet_id      = aws_subnet.subnet_az1.id
  route_table_id = aws_route_table.main_route_table.id
}

resource "aws_route_table_association" "subnet_az2_association" {
  subnet_id      = aws_subnet.subnet_az2.id
  route_table_id = aws_route_table.main_route_table.id
}

# ECS Cluster for request-validator
resource "aws_ecs_cluster" "request-validator-cluster" {
  name = "request-validator-cluster"
}

# ECS Cluster for message-uploader
resource "aws_ecs_cluster" "message-uploader-cluster" {
  name = "message-uploader-cluster"
}

# IAM Role for ECS Tasks (Both Microservices)
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

# Task Definition for request validator
resource "aws_ecs_task_definition" "request-validator-task" {
  family                   = "request-validator-task"
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  
  container_definitions = jsonencode([{
    name      = "request-validator-container"
    image     = "329599656414.dkr.ecr.eu-north-1.amazonaws.com/request-validator:latest" 
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [
      {
        containerPort = 80
        hostPort      = 80
        protocol      = "tcp"
      },
    ]
  }])
}

# Task Definition for message uploader
resource "aws_ecs_task_definition" "message-uploader-task" {
  family                   = "message-uploader-task"
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  
  container_definitions = jsonencode([{
    name      = "message-uploader-container"
    image     = "329599656414.dkr.ecr.eu-north-1.amazonaws.com/message-uploader:latest" 
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [
      {
        containerPort = 80
        hostPort      = 80
        protocol      = "tcp"
      },
    ]
  }])
}

# ECS Service for request validator
resource "aws_ecs_service" "request-validator-service" {
  name            = "request-validator-service"
  cluster         = aws_ecs_cluster.request-validator-cluster.id
  task_definition = aws_ecs_task_definition.request-validator-task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.subnet_az1.id, aws_subnet.subnet_az2.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main_target_group.arn
    container_name   = "request-validator-container"
    container_port   = 80
  }
}

# ECS Service for message uploader
resource "aws_ecs_service" "message-uploader-service" {
  name            = "message-uploader-service"
  cluster         = aws_ecs_cluster.message-uploader-cluster.id
  task_definition = aws_ecs_task_definition.message-uploader-task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.subnet_az1.id, aws_subnet.subnet_az2.id]
    assign_public_ip = true
  }
}

# Validated requests SQS Queue
resource "aws_sqs_queue" "email_queue" {
  name = "email-processing-queue"
}

# S3 Bucket (message uploader service uploads data here)
resource "aws_s3_bucket" "email_storage" {
  bucket = "email-storage-bucket-unique-id"  # Ensure the bucket name is globally unique
}

# Application Load Balancer
resource "aws_lb" "main_lb" {
  name               = "main-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.subnet_az1.id, aws_subnet.subnet_az2.id]

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
}

# Security Group for Load Balancer
resource "aws_security_group" "lb_sg" {
  name        = "lb-sg"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Target Group for Load Balancer
resource "aws_lb_target_group" "main_target_group" {
  name     = "main-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
  target_type = "ip"
}

# Listener for Load Balancer
resource "aws_lb_listener" "main_listener" {
  load_balancer_arn = aws_lb.main_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main_target_group.arn
  }
}