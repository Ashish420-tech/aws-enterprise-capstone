# AWS Enterprise DevSecOps Capstone Project

## Overview

This project demonstrates the implementation of a production-style AWS DevSecOps platform using Infrastructure as Code, Kubernetes, CI/CD, Security Scanning, Containerization, and Cloud-Native deployment practices.

The objective was to build a complete software delivery pipeline that automates infrastructure provisioning, application deployment, code quality validation, and security scanning on AWS.

---

# Architecture

```text
Developer
    ↓
GitHub Repository
    ↓
Jenkins CI/CD
    ↓
SonarQube Analysis
    ↓
Quality Gate Validation
    ↓
OWASP Dependency Check
    ↓
Docker Image Build
    ↓
Amazon ECR
    ↓
Amazon EKS
    ↓
AWS Load Balancer
    ↓
Application Access
```

---

# Technology Stack

## Cloud

* AWS
* Amazon EKS
* Amazon ECR
* Amazon EC2
* Amazon VPC
* Amazon S3
* DynamoDB

## Infrastructure as Code

* Terraform

## CI/CD

* Jenkins
* Jenkins Pipelines

## Containerization

* Docker

## Kubernetes

* Amazon EKS
* Helm
* Metrics Server
* EBS CSI Driver
* IRSA

## Security

* SonarQube
* OWASP Dependency Check

## Application

* Python Flask

---

# Infrastructure Provisioning

Infrastructure was provisioned using Terraform with:

* Remote State Backend (S3)
* State Locking (DynamoDB)
* Custom VPC
* Public Subnets
* Private Subnets
* NAT Gateway
* Security Groups
* EKS Cluster
* Managed Node Group

### AWS Region

```text
ap-south-1
```

### EKS Cluster

```text
Cluster Name: dev-enterprise-eks
```

### Node Group

```text
dev-node-group
```

### Worker Nodes

```text
4 x c7i-flex.large
```

---

# Storage Configuration

Implemented Kubernetes persistent storage using:

* OIDC Provider
* IAM Roles for Service Accounts (IRSA)
* Amazon EBS CSI Driver
* Dynamic Provisioning
* gp3 StorageClass

---

# Jenkins Setup

Jenkins was deployed on Amazon EKS using Helm.

## Features

* Persistent Storage
* Kubernetes Integration
* LoadBalancer Access

## Installed Plugins

* Git
* GitHub
* Pipeline
* Kubernetes
* Docker
* SonarQube Scanner
* OWASP Dependency Check
* Blue Ocean
* Credentials
* Configuration as Code

---

# SonarQube Integration

SonarQube was deployed on Kubernetes and integrated with Jenkins.

## Implemented

* SonarQube Analysis
* Jenkins Integration
* Authentication Token
* Webhook Configuration
* Quality Gates

## Results

```text
Sonar Analysis: SUCCESS
Quality Gate: PASSED
```

---

# OWASP Dependency Check

Integrated OWASP Dependency Check into the Jenkins pipeline.

## Features

* Vulnerability Scanning
* NVD Database Synchronization
* HTML Report Generation

---

# Containerization

Application containerized using Docker.

## Application

```text
Python Flask
```

## Docker Image

```text
aws-enterprise-capstone:v1
```

---

# Amazon ECR

Private container registry used for image storage.

## Repository

```text
aws-enterprise-capstone/app
```

## Image

```text
742820980479.dkr.ecr.ap-south-1.amazonaws.com/aws-enterprise-capstone/app:v1
```

---

# Kubernetes Deployment

Application deployed on Amazon EKS.

## Namespace

```text
enterprise
```

## Deployment

```text
enterprise-app
```

## Replicas

```text
2
```

## Service Type

```text
LoadBalancer
```

---

# Application Health Verification

Root Endpoint:

```bash
curl http://<load-balancer-dns>
```

Response:

```json
{
  "application":"aws-enterprise-capstone",
  "environment":"dev",
  "hostname":"enterprise-app",
  "status":"healthy"
}
```

Health Endpoint:

```bash
curl http://<load-balancer-dns>/health
```

Response:

```text
OK
```

---

# CI/CD Pipeline Flow

```text
GitHub
   ↓
Jenkins
   ↓
Source Checkout
   ↓
Workspace Validation
   ↓
SonarQube Analysis
   ↓
Quality Gate
   ↓
OWASP Dependency Check
   ↓
Report Publishing
   ↓
Docker Build
   ↓
Amazon ECR
   ↓
Amazon EKS Deployment
```

---

# Key Achievements

✅ Infrastructure provisioned using Terraform

✅ Remote state management using S3 and DynamoDB

✅ Amazon EKS cluster deployed

✅ Dynamic Persistent Volume provisioning

✅ Jenkins deployed on Kubernetes

✅ SonarQube integrated with Jenkins

✅ Quality Gate enforcement implemented

✅ OWASP Dependency Check integrated

✅ Docker image creation and testing completed

✅ Amazon ECR integration completed

✅ Kubernetes application deployment completed

✅ AWS LoadBalancer exposure completed

✅ End-to-end DevSecOps workflow validated

---

# Future Enhancements

The next phase of the project will include:

* Automated Docker Build from Jenkins
* Automated ECR Push
* Automated EKS Deployment
* Trivy Image Scanning
* Prometheus Monitoring
* Grafana Dashboards
* ArgoCD GitOps
* Falco Runtime Security
* Kyverno Policy Enforcement
* External Secrets Operator

---

# Learning Outcomes

This project provided hands-on experience with:

* AWS Cloud Infrastructure
* Infrastructure as Code (Terraform)
* Kubernetes Administration
* CI/CD Pipelines
* Containerization
* Cloud-Native Security
* DevSecOps Practices
* Amazon EKS Operations
* Jenkins Automation
* Security Scanning and Compliance
* Production Deployment Workflows

```
```
