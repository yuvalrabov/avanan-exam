# Avanan Home Exam

This project implements a system of two containerized microservices using AWS services (ECS, S3, ELB, SQS) with infrastructure provisioned via Terraform and CI/CD pipelines managed by Jenkins.

---

## Table of Contents

- [System Overview](#system-overview)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Services](#services)
  - [Request Validator](#request-validator)
  - [Message Uploader](#message-uploader)
- [CI/CD Pipelines](#cicd-pipelines)
- [Testing](#testing)
- [Monitoring](#monitoring)
- [Repository Structure](#repository-structure)

---

## System Overview

The project includes:
1. Two microservices:
   - **Request Validator**: Validates a token and publishes payloads to an SQS queue.
   - **Message Uploader**: Consumes messages from the SQS queue and uploads them to an S3 bucket.
2. Infrastructure as Code using Terraform.
3. CI/CD pipelines:
   - CI: Builds Docker images and pushes them to DockerHub/ECR.
   - CD: Deploys services to ECS.
4. Optional features: Tests and monitoring with Grafana/Prometheus.

---

## Prerequisites

- **AWS Account** (Free Tier)
- AWS CLI configured with access keys.
- Terraform installed.
- Docker installed.
- Jenkins or another CI/CD tool installed.

---

## Installation

1. **Clone the Repository**:
   ```bash
   git clone <repo-url>
   cd <repo-directory>

## Services

### Request Validator
- **Description:** A REST API receiving requests via an ELB, validating a token, and publishing the payload to an SQS queue.
- **Request Example:**
```
{
  "data": {
    "email_subject": "Happy new year!",
    "email_sender": "John Doe",
    "email_timestream": "1693561101",
    "email_content": "Just want to say... Happy new year!!!"
  },
  "token": "sometoken"
}
```
- **Validation**
    - The service will validate the token passed in the request against a stored value in AWS SSM
    - The request must contain all 4 data fields mentioned in the example: email_subject, email_sender, email_timestream & email_content. 

### Message Uploader
- **Description:** Periodically pulls the SQS requests queue and uploads messages to the S3 bucket. 
- **interval:** Pulls every X seconds (configurable in `.env`).
