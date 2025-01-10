variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "task_definition_family" {
  description = "Task definition family"
  type        = string
}

variable "container_name" {
  description = "Container name for ECS service"
  type        = string
}

variable "image_url" {
  description = "ECR Image URL for ECS task"
  type        = string
}

variable "service_name" {
  description = "ECS service name"
  type        = string
}

variable "desired_count" {
  description = "Number of desired instances of the task"
  type        = number
}

variable "subnets" {
  description = "List of subnet IDs for ECS task"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs for ECS task"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the target group for load balancing"
  type        = string
}
