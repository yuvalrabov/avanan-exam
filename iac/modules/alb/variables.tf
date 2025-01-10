variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "load_balancer_name" {
  type = string
}
