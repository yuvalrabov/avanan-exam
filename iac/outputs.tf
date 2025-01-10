output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "sqs_url" {
  value = aws_sqs_queue.email_queue.id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.email_storage.bucket
}

output "lb_url" {
  value = aws_lb.main_lb.dns_name
}