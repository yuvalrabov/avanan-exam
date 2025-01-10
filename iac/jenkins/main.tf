provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "jenkins" {
  ami           = "ami-02df5cb5ad97983ba" # Amazon Linux 2 AMI
  instance_type = "t3.micro"
  key_name      = "jenkins-key-pair"
  tags = {
    Name = "Jenkins-Server"   
  }

  security_groups = [aws_security_group.jenkins_sg.name]

  user_data = file("install-jenkins.sh")
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Allow Jenkins and SSH"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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