output "load_balancer_arn" {
  value = aws_lb.main_lb.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.main_target_group.arn
}

output "lb_url" {
  value = aws_lb.main_lb.dns_name
}