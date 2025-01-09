# SQS Module
resource "aws_sqs_queue" "this" {
  name = var.queue_name
}

output "queue_url" {
  value = aws_sqs_queue.this.url
}