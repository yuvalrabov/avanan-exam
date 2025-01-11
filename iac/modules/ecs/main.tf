resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_caller_identity" "current" {}

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
      }
    ]
  })
}

# IAM policy to allow ECS Exec
resource "aws_iam_policy" "ecs_exec_policy" {
  name        = "ecs-exec-policy"
  description = "Policy to allow ECS Exec commands"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ecs:ExecuteCommand"
        Resource = "*"
      }
    ]
  })
}

# Attach ECS Exec policy to the ECS task role
resource "aws_iam_role_policy_attachment" "ecs_exec_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_exec_policy.arn
}

# IAM policy for SSM Parameter Store access
resource "aws_iam_policy" "ssm_parameter_access" {
  name        = "ssm-parameter-access-policy"
  description = "Policy to allow access to specific SSM Parameter Store parameters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ssm:GetParameter"
        Resource = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.ssm_parameter_name}"
      }
    ]
  })
}

# Attach SSM Parameter Store access policy to the ECS task role
resource "aws_iam_role_policy_attachment" "ssm_access_policy_attachment" {
  for_each = { for idx, service in var.services : idx => service if service.name == "request-validator-service" }
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ssm_parameter_access.arn
}

resource "aws_ecs_task_definition" "task_definition" {
  count                   = length(var.task_definitions)
  family                  = var.task_definitions[count.index].name
  execution_role_arn      = aws_iam_role.ecs_task_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn
  network_mode            = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                     = var.task_definitions[count.index].cpu
  memory                  = var.task_definitions[count.index].memory

  container_definitions = jsonencode([{
    name         = var.services[count.index].container_name
    image        = var.task_definitions[count.index].image
    cpu          = var.task_definitions[count.index].cpu
    memory       = var.task_definitions[count.index].memory
    essential    = true
    portMappings = var.task_definitions[count.index].port_mappings
    execEnabled   = true
  }])
}

resource "aws_ecs_service" "service" {
  count            = length(var.services)
  name             = var.services[count.index].name
  cluster          = aws_ecs_cluster.cluster.id
  task_definition  = aws_ecs_task_definition.task_definition[count.index].arn
  desired_count    = var.services[count.index].desired_count
  launch_type      = "FARGATE"
  force_new_deployment = true
  triggers = {
    redeployment = plantimestamp()
  }

  network_configuration {
    subnets          = var.vpc_subnet_ids
    assign_public_ip = true
  }

  dynamic "load_balancer" {
    for_each = var.services[count.index].name == "request-validator-service" ? [1] : []
    content {
      target_group_arn = var.services[count.index].target_group_arn
      container_name   = var.services[count.index].container_name
      container_port   = var.services[count.index].container_port
    }
  }
  
}
