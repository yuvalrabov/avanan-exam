output "vpc_id" {
  value = module.vpc.vpc_id
}

output "sqs_url" {
  value = aws_sqs_queue.email_queue.id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.email_storage.bucket
}

output "lb_url" {
  value = module.alb.lb_url
}