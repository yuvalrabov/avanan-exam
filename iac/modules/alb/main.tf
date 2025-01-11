resource "aws_security_group" "lb_sg" {
  name        = "lb-sg"
  description = "Allow inbound traffic on port 80"
  vpc_id      = var.vpc_id

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

resource "aws_lb" "main_lb" {
  name                        = var.load_balancer_name
  internal                    = false
  load_balancer_type          = "application"
  security_groups             = [aws_security_group.lb_sg.id]
  subnets                     = var.subnet_ids
  enable_deletion_protection  = false
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_target_group" "main_target_group" {
  name     = "main-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "main_listener" {
  load_balancer_arn = aws_lb.main_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main_target_group.arn
  }
}