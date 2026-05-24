AWS Enterprise DevOps Capstone Project
Enterprise-Grade DevOps Platform on AWS
Executive Summary

This project demonstrates the end-to-end implementation of a production-grade enterprise DevOps platform on AWS, built using Infrastructure as Code, configuration management, containerization, Kubernetes orchestration, CI/CD automation, observability, and security hardening.

The goal was to simulate how a real enterprise engineering team would design, deploy, secure, monitor, and automate a cloud-native application platform.

The platform includes:

Infrastructure provisioning with Terraform
Server configuration with Ansible
Containerized Python Flask production application
Amazon Elastic Container Registry (ECR)
Amazon Elastic Kubernetes Service (EKS)
Helm-based Kubernetes deployments
GitHub Actions CI/CD pipelines
GitHub OIDC federation (passwordless AWS authentication)
CloudWatch observability stack
SNS alerting
CloudTrail auditing
IAM Access Analyzer
VPC Flow Logs
Secrets Manager integration
Enterprise security scanning with Trivy
Business Problem Statement

Modern enterprises require:

repeatable infrastructure provisioning
secure deployment automation
zero static cloud credentials
scalable container orchestration
centralized monitoring
automated security validation
audit logging
cost-conscious cloud governance

Manual infrastructure and deployments introduce:

configuration drift
human error
security risk
slow delivery
poor scalability

This project solves these problems using enterprise DevOps engineering practices.

Architecture Overview
High-Level Architecture
Developer
   |
   v
GitHub Repository
   |
   +-----------------------------+
   | GitHub Actions CI/CD        |
   |-----------------------------|
   | Terraform CI                |
   | App CI                      |
   | Deploy to EKS               |
   | Enterprise Security Scan    |
   +-----------------------------+
   |
   v
GitHub OIDC Federation
   |
   v
AWS IAM Role Assumption
   |
   +-----------------------------+
   | AWS Infrastructure          |
   +-----------------------------+
            |
            +-------------------+
            | Terraform         |
            +-------------------+
                     |
                     v
          +------------------------+
          | AWS Networking         |
          |------------------------|
          | VPC                    |
          | Public Subnets         |
          | Private Subnets        |
          | Internet Gateway       |
          | NAT Gateway            |
          | Route Tables           |
          | Security Groups        |
          +------------------------+
                     |
                     +-------------------+
                     |                   |
                     v                   v
              EC2 (SSM-only)        EKS Cluster
              Ansible Host          Managed Node Group
                                         |
                                         v
                                   Kubernetes
                                         |
                                         v
                                      Helm
                                         |
                                         v
                                Flask Production App
                                         |
                                         v
                                 LoadBalancer Service
                                         |
                                         v
                                  End Users / Browser

Observability:
CloudWatch
Fluent Bit
Container Insights
SNS Alerts

Security:
CloudTrail
Access Analyzer
VPC Flow Logs
Secrets Manager
Trivy Scanning
OIDC Federation
Technology Stack
Category	Technology
Cloud	AWS
IaC	Terraform
Config Mgmt	Ansible
Containers	Docker
Registry	Amazon ECR
Orchestration	Amazon EKS
Packaging	Helm
CI/CD	GitHub Actions
Authentication	GitHub OIDC
Monitoring	CloudWatch
Logging	Fluent Bit
Alerts	SNS
Security Scanning	Trivy
Secrets	AWS Secrets Manager
Project Structure
aws-enterprise-capstone/
│
├── terraform/
│   ├── modules/
│   │   ├── networking/
│   │   ├── ec2/
│   │   ├── iam/
│   │   └── security/
│   │
│   └── environments/
│       └── dev/
│
├── ansible/
│   ├── playbooks/
│   │   ├── bootstrap.yml
│   │   └── deploy.yml
│   │
│   ├── inventory/
│   └── roles/
│       ├── common/
│       ├── docker/
│       └── app/
│
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
│
├── helm/
│   └── aws-enterprise-capstone/
│
├── k8s/
│   └── base/
│
└── .github/
    └── workflows/
        ├── terraform-ci.yml
        ├── app-ci.yml
        ├── deploy.yml
        └── security-scan.yml
Implementation Journey
Phase 1 — Infrastructure as Code (Terraform)
Objective

Provision reusable AWS infrastructure.

Components Built
Networking

Provisioned:

VPC
Internet Gateway
NAT Gateway
Public Subnets
Private Subnets
Route Tables
Associations

Purpose:

isolate workloads
controlled ingress/egress
enterprise network segmentation
Security

Provisioned:

security groups
IAM roles
EC2 instance profile

Purpose:

least privilege
controlled traffic
IAM governance
EC2

Provisioned:

Private EC2 instance with:

no SSH
SSM-only administration
hardened access

Purpose:

Ansible execution target.

Validation
terraform init
terraform validate
terraform plan
terraform apply
Issues Faced
1. Resource Dependency Ordering

Problem:

Terraform attempted dependent resource creation before prerequisites.

Example:

NAT before Elastic IP
route before gateway

Fix:

Used explicit dependencies.

2. IAM Propagation Delay

Problem:

Role creation succeeded but attachment not immediately usable.

Fix:

Retry after propagation delay.

3. Route Table Misconfiguration

Problem:

Subnet traffic blackholed.

Fix:

Correct route associations.

Phase 2 — Configuration Management (Ansible)
Objective

Automate EC2 configuration.

Playbooks
bootstrap.yml

Purpose:

Initial server bootstrap.

Tasks:

system package updates
install dependencies
configure baseline packages

Flow:

bootstrap.yml
   |
   +--> common role
deploy.yml

Purpose:

Application deployment automation.

Tasks:

Docker install
container deployment
application configuration

Flow:

deploy.yml
   |
   +--> docker role
   |
   +--> app role
Roles
common role

Tasks:

OS updates
package installation
system prep
docker role

Tasks:

install Docker engine
enable Docker service
runtime configuration
app role

Tasks:

pull container image
start production container
validate deployment
Issues Faced
1. Package Manager Differences

Problem:

Ubuntu vs Amazon Linux package manager mismatch.

Fix:

Adjusted module usage.

2. SSM Connectivity

Problem:

No SSH access.

Fix:

Used:

community.aws.aws_ssm

Enterprise-grade secure remote execution.

3. Module Compatibility

Problem:

Ansible module syntax mismatch.

Fix:

Corrected task definitions.

Phase 3 — Containerization
Objective

Production-ready application containerization.

Application

Python Flask service.

Endpoints:

/
/health
Docker Build

Production container:

Python slim image
dependency installation
non-root execution
hardened runtime
Final Docker Security Controls

Implemented:

non-root user
minimal base image
no privilege escalation
reduced attack surface
Issues Faced
1. Missing Dockerfile Path

Problem:

Build failed:

failed to read dockerfile

Fix:

Correct build context.

2. Vulnerability Findings

Trivy detected:

jaraco.context
wheel CVEs

Fix:

dependency upgrades
workflow scope refinement
Phase 4 — Amazon ECR
Objective

Central container registry.

Steps

Created:

aws ecr create-repository

Authenticated:

aws ecr get-login-password

Tagged image.

Pushed image.

Security

Enabled vulnerability scanning.

Issues Faced
ECR Auth

Problem:

Login failures.

Fix:

Correct AWS auth flow.

Phase 5 — CI/CD Automation
GitHub Actions Workflows
terraform-ci.yml

Purpose:

Terraform quality checks.

Stages:

checkout
terraform init
validate
fmt
plan
app-ci.yml

Purpose:

Build and publish container.

Stages:

checkout
AWS auth
ECR login
docker build
docker push
deploy.yml

Purpose:

Continuous deployment to EKS.

Stages:

AWS auth via OIDC
kubeconfig update
cluster auth validation
Helm deploy
rollout verification
security-scan.yml

Purpose:

Enterprise security validation.

Stages:

Trivy image scan
Trivy IaC scan
CI/CD Architecture
Git Push
   |
   +--> Terraform CI
   |
   +--> App CI
   |
   +--> Enterprise Security Scan
   |
   +--> Deploy to EKS
CI/CD Issues Faced
1. Invalid Trivy Action Version

Problem:

unable to find version

Fix:

Updated action reference.

2. OIDC Permission Failure

Problem:

Could not load credentials

Fix:

Added:

id-token: write
3. SARIF Upload Failure

Problem:

GitHub integration restriction.

Fix:

Removed SARIF upload dependency.

4. Security Findings

Detected:

Docker security issues
Kubernetes hardening gaps
Terraform risks

Fix:

Iterative remediation.

Phase 6 — Kubernetes / EKS
Objective

Production container orchestration.

Provisioned

Amazon EKS:

managed control plane
managed node groups
OIDC provider
Kubernetes Resources

Deployed:

deployment
service
namespace
Helm Migration

Moved from raw manifests to Helm.

Benefits:

versioned deployments
parameterization
repeatability
rollback capability
Security Hardening

Added:

runAsNonRoot
readOnlyRootFilesystem
dropped Linux capabilities
no privilege escalation
Issues Faced
1. EKS Auth Failures

Problem:

kubectl auth denied.

Fix:

Access entries + admin policy.

2. LoadBalancer Delays

Problem:

ELB provisioning latency.

Fix:

wait + validation.

3. Deployment Rollout Failures

Fix:

Helm rollout validation.

Phase 7 — Observability
Objective

Production monitoring.

Implemented
CloudWatch Container Insights

Metrics:

CPU
memory
node metrics
pod metrics
Fluent Bit

Log forwarding.

Dashboard

Created:

enterprise-eks-dashboard
Alarms

Configured:

threshold monitoring
operational alerting
SNS

Email alert delivery.

Issues Faced
Metric Delay

CloudWatch metric ingestion lag.

Fix:

wait + validation.

Phase 8 — Security Hardening
Implemented
GitHub OIDC Federation

Purpose:

Eliminate static AWS credentials.

Result:

Passwordless GitHub → AWS auth.

CloudTrail

Audit logging enabled.

IAM Access Analyzer

Privilege visibility.

VPC Flow Logs

Network audit visibility.

Secrets Manager

Integrated secure runtime secret retrieval.

Validated from Kubernetes pod.

Trivy Security Scanning

Implemented:

container scan
IaC scan
Issues Faced
IAM Propagation Delay

Policy attachment delay.

Fix:

retry after propagation.

Secret Validation Pod Failure

Initial transient pod issue.

Fix:

validated with logs.

Validation Commands
Kubernetes
kubectl get pods -A
kubectl get svc -A
EKS
aws eks describe-cluster
CloudWatch
aws cloudwatch list-dashboards
SNS
aws sns list-topics
CloudTrail
aws cloudtrail describe-trails
Flow Logs
aws ec2 describe-flow-logs
Access Analyzer
aws accessanalyzer list-analyzers
GitHub Actions
gh run list
Security Controls Summary
Control	Status
GitHub OIDC Federation	✅
No Static AWS Keys	✅
SSM-only EC2 Access	✅
Non-root Containers	✅
Hardened Kubernetes Runtime	✅
Trivy Image Scanning	✅
Trivy IaC Scanning	✅
CloudTrail	✅
IAM Access Analyzer	✅
VPC Flow Logs	✅
Secrets Manager	✅
ECR Vulnerability Scanning	✅
Cost Optimization

Cleanup order:

delete service
uninstall Helm release
delete namespace
delete EKS cluster
delete secret
terraform destroy
delete ECR repo

Reason:

Avoid dependency failures.

Lessons Learned

Key enterprise lessons:

OIDC is superior to static credentials
IaC requires dependency discipline
Kubernetes security defaults are insufficient
observability must be designed early
CI/CD security gates expose real weaknesses
least privilege IAM matters
container hardening is essential
monitoring is non-optional
secret management should never rely on hardcoded values
