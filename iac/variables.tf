variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnets" {
  default = [
    {
      cidr_block              = "10.0.1.0/24"
      availability_zone       = "eu-north-1a"
      map_public_ip_on_launch = true
      tags = { Name = "subnet-az1" }
    },
    {
      cidr_block              = "10.0.2.0/24"
      availability_zone       = "eu-north-1b"
      map_public_ip_on_launch = true
      tags = { Name = "subnet-az2" }
    }
  ]
}

variable "task_definitions" {
  default = [
    {
      name          = "request-validator-task"
      image         = "yuvalrabo/request-validator:latest"
      cpu           = 256
      memory        = 512
      port_mappings = [
        { containerPort = 80, hostPort = 80, protocol = "tcp" }
      ]
    },
    {
      name          = "message-uploader-task"
      image         = "yuvalrabo/message-uploader:latest"
      cpu           = 256
      memory        = 512
      port_mappings = [
        { containerPort = 80, hostPort = 80, protocol = "tcp" }
      ]
    }
  ]
}

variable "services" {
  default = [
    {
      name             = "request-validator-service"
      desired_count    = 2
      target_group_arn = ""
      container_name   = "request-validator-container"
      container_port   = 80
    },
    {
      name             = "message-uploader-service"
      desired_count    = 2
      target_group_arn = ""
      container_name   = "message-uploader-container"
      container_port   = 80
    }
  ]
}

