# Avanan Home Exam

This project implements a system of two containerized microservices using AWS services (ECS, S3, ELB, SQS) with infrastructure provisioned via Terraform and CI/CD pipelines managed by Jenkins.

---

## Table of Contents

- [System Overview](#system-overview)
- [Repository Structure](#repository-structure)
- [Services](#services)
  - [Request Validator](#request-validator)
  - [Message Uploader](#message-uploader)
- [IaC](#iac)
- [CI/CD Pipeline](#cicd-pipeline)

---

## System Overview

The project includes:
1. Two microservices:
   - **Request Validator**: Validates a token and publishes payloads to an SQS queue.
   - **Message Uploader**: Consumes messages from the SQS queue and uploads them to an S3 bucket.
2. Infrastructure as Code using Terraform.
3. CI/CD pipeline using GitHub Actions.

---

## Repository Structure

```
│   README.md
├───.github
│   └───workflows
├───iac
│   └───modules
└───services
    ├───request-validator
    └───message-uploader
```

---
## Services

```
├───services
    ├───request-validator
    │       app.py
    │       Dockerfile
    │       requirements.txt
    └───message-uploader
            app.py
            Dockerfile
            requirements.txt
```

### Request Validator
- **Description:** A REST API receiving requests via an ALB, validating a token, and publishing the payload to an SQS queue.
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
- **Validation:**
    - The service would validate the token passed in the request against a stored value in AWS SSM
    - The request must contain all 4 data fields mentioned in the example: email_subject, email_sender, email_timestream & email_content. 

### Message Uploader
- **Description:** Periodically pulls the SQS requests queue and uploads messages to the S3 bucket. 
- **interval:** Pulls every X seconds (configurable in `.env`, default is 5 minutes).

---

## IaC

```
├───iac
│   │   main.tf
│   │   outputs.tf
│   │   variables.tf
│   └───modules
│       ├───alb
│       │       main.tf
│       │       outputs.tf
│       │       variables.tf
│       ├───ecs
│       │       main.tf
│       │       outputs.tf
│       │       variables.tf
│       └───vpc
│               main.tf
│               outputs.tf
│               variables.tf
```

The AWS infrastructure is managed using Terraform. 
The iac directory contains some modules, as well as the root configuration. 

---

## CI/CD Pipeline

```
├───.github
│   └───workflows
│           build-and-deploy.yml
```

The CI/CD process is built with GitHub Actions, in one Workflow. 
The Workflow contains 3 jobs:
   - Detect Changes: Using selective build mechanism to promote idempotency in the CI/CD process, making sure only changed components would be triggered.
   - Build: Builds Docker images and pushes them to DockerHub. This job would be triggered only if the previous job detected changes in the services code.
   - Deploy: Deploys Terraform to AWS.
