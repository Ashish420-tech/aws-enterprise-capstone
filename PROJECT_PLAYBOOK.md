# AWS Enterprise DevOps Capstone — PROJECT_PLAYBOOK

## Executive Overview

This document is the end-to-end implementation runbook for the AWS Enterprise DevOps Capstone project, covering architecture, infrastructure provisioning, configuration management, containerization, CI/CD, Kubernetes deployment, observability, security hardening, troubleshooting, validation, and cleanup.

## Sections

1. Environment Preparation
2. AWS Authentication Setup
3. Repository Bootstrap
4. Terraform Infrastructure Runbook
5. EC2 SSM Access Runbook
6. Ansible Configuration Management Runbook
7. Docker Containerization Runbook
8. Amazon ECR Runbook
9. GitHub OIDC Federation Runbook
10. GitHub Actions CI/CD Runbook
11. Amazon EKS Runbook
12. Kubernetes Deployment Runbook
13. Helm Deployment Runbook
14. Observability Runbook
15. Security Hardening Runbook
16. Secrets Manager Integration Runbook
17. Troubleshooting Encyclopedia
18. Validation Checklist
19. Cost Cleanup Runbook
20. Interview Talking Points

## Environment Preparation

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y unzip curl wget git jq python3 python3-pip docker.io ansible
```

## AWS Tooling

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip
sudo ./aws/install
```

## AWS Authentication Setup

```bash
aws configure
aws sts get-caller-identity
aws configure list
```

Expected validation:

* account ID visible
* authenticated IAM principal confirmed

## Repository Bootstrap

```bash
git init
mkdir -p ~/aws-enterprise-capstone
cd ~/aws-enterprise-capstone
gh repo create aws-enterprise-capstone --public --source=. --remote=origin --push
```

Recommended structure:

```text
terraform/
ansible/
app/
helm/
k8s/
.github/workflows/
```

## Terraform Infrastructure Runbook

### Objective

Provision enterprise AWS infrastructure using Infrastructure as Code.

### Execution Commands

```bash
cd ~/aws-enterprise-capstone/terraform/environments/dev
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply -auto-approve
```

### Infrastructure Components

* VPC
* Internet Gateway
* NAT Gateway
* Public subnets
* Private subnets
* Route tables
* Security groups
* IAM EC2 role
* Instance profile
* Private EC2 instance

### Validation

```bash
terraform output
aws ec2 describe-vpcs --region ap-south-1
aws ec2 describe-subnets --region ap-south-1
aws ec2 describe-route-tables --region ap-south-1
```

### EC2 SSM Access

```bash
aws ssm start-session --target <INSTANCE_ID>
```

## Ansible Configuration Management Runbook

### Inventory Validation

```bash
cd ~/aws-enterprise-capstone/ansible
ansible-inventory -i inventory/aws_ec2.yml --graph
```

### Bootstrap Execution

```bash
ansible-playbook -i inventory/aws_ec2.yml playbooks/bootstrap.yml
```

### Application Deployment

```bash
ansible-playbook -i inventory/aws_ec2.yml playbooks/deploy.yml
```

### Roles

* common
* docker
* app

### Validation

```bash
docker --version
systemctl status docker
```

## Docker Containerization Runbook

### Build

```bash
cd ~/aws-enterprise-capstone
docker build -t aws-enterprise-capstone/app:latest ./app
```

### Local Validation

```bash
docker run -d -p 5000:5000 aws-enterprise-capstone/app:latest
curl http://localhost:5000/health
```

### Hardening

Implemented:

* non-root user
* minimal slim base image
* hardened runtime
* reduced privileges

## Amazon ECR Runbook

### Repository Creation

```bash
aws ecr create-repository \
  --repository-name aws-enterprise-capstone/app \
  --region ap-south-1
```

### Authentication

```bash
aws ecr get-login-password --region ap-south-1 | \
docker login --username AWS --password-stdin 742820980479.dkr.ecr.ap-south-1.amazonaws.com
```

### Push

```bash
docker tag aws-enterprise-capstone/app:latest 742820980479.dkr.ecr.ap-south-1.amazonaws.com/aws-enterprise-capstone/app:latest
docker push 742820980479.dkr.ecr.ap-south-1.amazonaws.com/aws-enterprise-capstone/app:latest
```

## GitHub OIDC Federation Runbook

### Purpose

Passwordless GitHub Actions authentication into AWS.

### Validation

```bash
aws iam get-role --role-name GitHubActionsEnterpriseCapstoneRole
```

## GitHub Actions CI/CD Runbook

### Terraform CI

Validates infrastructure code.

Execution checks:

```bash
gh run list
terraform fmt -check
terraform validate
```

### App CI

Builds and pushes Docker image to ECR.

Validation:

```bash
gh run watch
docker pull 742820980479.dkr.ecr.ap-south-1.amazonaws.com/aws-enterprise-capstone/app:latest
```

### Deploy to EKS

Pipeline stages:

* AWS auth via OIDC
* kubeconfig update
* Helm deployment
* rollout verification

Validation:

```bash
gh run watch
kubectl get pods -n enterprise
```

### Enterprise Security Scan

Runs:

* Trivy image scan
* Trivy IaC scan

Validation:

```bash
gh run list --workflow "Enterprise Security Scan"
```

## Amazon EKS Runbook

### Cluster Provisioning

```bash
eksctl create cluster \
  --name aws-enterprise-eks \
  --region ap-south-1 \
  --nodes 2 \
  --node-type t3.medium \
  --managed
```

### Configure kubectl

```bash
aws eks update-kubeconfig \
  --region ap-south-1 \
  --name aws-enterprise-eks
```

### Validation

```bash
kubectl get nodes
kubectl cluster-info
```

### OIDC Association

```bash
eksctl utils associate-iam-oidc-provider \
  --cluster aws-enterprise-eks \
  --approve \
  --region ap-south-1
```

## Kubernetes Deployment Runbook

### Namespace Creation

```bash
kubectl create namespace enterprise
```

### Deployment Validation

```bash
kubectl get deployments -n enterprise
kubectl get pods -n enterprise
kubectl rollout status deployment/aws-enterprise-capstone -n enterprise
```

### Service Validation

```bash
kubectl get svc -n enterprise
```

### Health Validation

```bash
curl http://<LOADBALANCER>/health
```

## Helm Deployment Runbook

### Install Release

```bash
helm upgrade --install aws-enterprise-capstone \
  ./helm/aws-enterprise-capstone \
  --namespace enterprise \
  --create-namespace
```

### Validation

```bash
helm list -n enterprise
kubectl get all -n enterprise
```

## Observability Runbook

### Container Insights

Enabled for EKS monitoring.

Validation:

```bash
aws cloudwatch list-dashboards --region ap-south-1
```

### Fluent Bit Logging

Validation:

```bash
kubectl get pods -A | grep fluent
```

### SNS Alerts

Validation:

```bash
aws sns list-topics --region ap-south-1
```

### CloudWatch Alarms

Validation:

```bash
aws cloudwatch describe-alarms --region ap-south-1
```

## Security Hardening Runbook

### CloudTrail

```bash
aws cloudtrail describe-trails --region ap-south-1
```

### IAM Access Analyzer

```bash
aws accessanalyzer list-analyzers --region ap-south-1
```

### VPC Flow Logs

```bash
aws ec2 describe-flow-logs --region ap-south-1
```

### Secrets Manager Integration

Create secret:

```bash
aws secretsmanager create-secret \
  --name enterprise/app/config \
  --secret-string '{"APP_ENV":"production","API_KEY":"enterprise-demo-secret"}' \
  --region ap-south-1
```

Validation pod:

```bash
kubectl run secret-test \
  --image=amazon/aws-cli \
  --restart=Never \
  --command -- \
  sh -c "aws sts get-caller-identity && aws secretsmanager get-secret-value --secret-id enterprise/app/config --region ap-south-1"
```

## Troubleshooting Encyclopedia

### GitHub OIDC Failure

Error:

```text
Could not load credentials
```

Fix:

```yaml
permissions:
  id-token: write
```

### Invalid Trivy Version

Error:

```text
unable to find version
```

Fix:
Updated action version.

### SARIF Upload Failure

Error:

```text
Resource not accessible by integration
```

Fix:
Removed SARIF upload dependency.

### Dockerfile Path Failure

Error:

```text
failed to read dockerfile
```

Fix:
Corrected build context.

### EKS Access Failure

Fix:
Configured access entries and cluster admin policy.

### Secrets Validation Failure

Fix:
Retested after IAM propagation.

## Final Validation Checklist

```bash
kubectl get pods -A
kubectl get svc -A
aws eks describe-cluster --name aws-enterprise-eks --region ap-south-1
aws cloudwatch list-dashboards --region ap-south-1
aws sns list-topics --region ap-south-1
aws cloudtrail describe-trails --region ap-south-1
aws ec2 describe-flow-logs --region ap-south-1
aws accessanalyzer list-analyzers --region ap-south-1
gh run list
```

## Cost Cleanup Runbook

### Cleanup Order

Delete service:

```bash
kubectl delete svc aws-enterprise-capstone -n enterprise
```

Uninstall Helm:

```bash
helm uninstall aws-enterprise-capstone -n enterprise
```

Delete namespace:

```bash
kubectl delete namespace enterprise
```

Delete EKS:

```bash
eksctl delete cluster --name aws-enterprise-eks --region ap-south-1
```

Delete secret:

```bash
aws secretsmanager delete-secret \
  --secret-id enterprise/app/config \
  --force-delete-without-recovery \
  --region ap-south-1
```

Terraform destroy:

```bash
cd ~/aws-enterprise-capstone/terraform/environments/dev
terraform destroy -auto-approve
```

Delete ECR:

```bash
aws ecr delete-repository \
  --repository-name aws-enterprise-capstone/app \
  --force \
  --region ap-south-1
```

## Interview Talking Points

Implemented enterprise-grade DevOps platform using:

* Terraform
* Ansible
* Docker
* ECR
* EKS
* Helm
* GitHub Actions
* GitHub OIDC
* CloudWatch
* SNS
* CloudTrail
* IAM Access Analyzer
* VPC Flow Logs
* Secrets Manager
* Trivy security scanning

