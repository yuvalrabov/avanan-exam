provider "aws" {
  region = "eu-north-1"
}

# SQS Module
module "sqs" {
  source    = "./modules/sqs"
  queue_name = "validated-requests"
}

# S3 Module
module "s3" {
  source     = "./modules/s3"
  bucket_name = "processed-messages"
}

output "sqs_url" {
  value = module.sqs.queue_url
}

output "s3_bucket_name" {
  value = module.s3.bucket_name
}