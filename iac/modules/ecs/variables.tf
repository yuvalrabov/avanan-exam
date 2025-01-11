variable "cluster_name" {
  type = string
}

variable "aws_region" {
  type = string
  default = "eu-north-1"
  
}

variable "task_definitions" {
  type = list(object({
    name            = string
    image           = string
    cpu             = number
    memory          = number
    port_mappings   = list(object({ containerPort = number, hostPort = number, protocol = string }))
  }))
}

variable "services" {
  type = list(object({
    name            = string
    desired_count   = number
    target_group_arn = string
    container_name  = string
    container_port  = number
  }))
}

variable "vpc_subnet_ids" {
  type = list(string)
}

variable "ssm_parameter_name" {
  type = string
  default = "ValidationToken" 
}