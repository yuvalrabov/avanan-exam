#!/bin/bash
yum update -y
yum install java-11-openjdk -y
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum install jenkins -y
systemctl start jenkins
systemctl enable jenkins
yum install docker
systemctl start docker
systemctl enable docker