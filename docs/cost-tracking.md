# Cost Tracking & Optimization Strategy

## Executive Overview

This document defines the cost management, optimization strategy, and financial governance model for the **AWS Enterprise Platform Engineering Capstone Project**.

As this platform evolves from a learning implementation into an enterprise-grade engineering showcase, cost visibility and optimization become critical operational concerns.

This document tracks:

- infrastructure cost drivers
- optimization opportunities
- architectural trade-offs
- environment governance
- future cost reduction strategy

---

# Architecture Cost Context

Current platform components:

- AWS VPC
- Public subnets
- Private subnets
- NAT Gateway
- Internet Gateway
- Route tables
- Security groups
- EC2 instances
- Amazon EKS cluster
- Managed node groups
- Amazon ECR
- S3 remote Terraform backend
- DynamoDB locking
- GitHub Actions CI/CD workflows

Future additions:

- AWS Load Balancer Controller
- Application Load Balancer
- Metrics Server
- HPA
- Prometheus
- Grafana
- Fluent Bit
- CloudWatch dashboards
- Secrets Manager
- WAF
- Route53
- ACM

---

# Major AWS Cost Drivers

## 1. Amazon EKS Control Plane

### Description

Amazon EKS charges separately for the managed Kubernetes control plane.

This is a fixed infrastructure cost.

Services included:

- API server
- etcd
- control plane management
- high availability management
- patching

### Cost Characteristics

- fixed monthly baseline
- always-on cost
- independent of workload traffic

### Optimization

Best practice:

Use only when Kubernetes orchestration is required.

Rationale:

This project intentionally uses EKS because Kubernetes platform engineering is a core project objective.

---

# 2. Managed Node Groups

## Description

EKS worker nodes run application workloads.

Cost depends on:

- instance family
- instance size
- node count
- runtime duration

Current examples:

```text
t3.medium
c7i-flex.large
```

### Cost Factors

Higher costs caused by:

- oversized instances
- idle nodes
- overprovisioning
- no autoscaling

---

## Optimization Strategy

Future improvements:

- Cluster Autoscaler
- HPA
- Spot instances
- mixed node groups
- workload rightsizing

Target model:

```text
Baseline:
1 on-demand node

Burst:
spot nodes
```

---

# 3. NAT Gateway

## Description

NAT Gateway enables private subnet outbound internet access.

Used for:

- package downloads
- EKS node internet access
- image pulls
- updates

---

## Cost Impact

NAT Gateway is one of the highest hidden AWS networking costs.

Charges include:

- hourly runtime
- outbound data transfer

---

## Optimization Strategy

Future options:

### Option 1

Single NAT Gateway (current learning architecture)

Pros:

- simple
- functional

Cons:

- less resilient

---

### Option 2

Multi-AZ NAT Gateway

Pros:

- resilient

Cons:

- expensive

---

### Option 3

VPC Endpoints

Use endpoints for:

- S3
- ECR
- STS
- CloudWatch

Benefits:

- reduced NAT traffic
- lower networking cost
- better security

Recommended future upgrade.

---

# 4. EC2 Instances

## Description

Current EC2 usage supports:

- application hosting
- automation experiments
- Ansible provisioning
- hybrid deployment workflows

---

## Cost Risks

- oversized instances
- always-on compute
- unused experimentation resources

---

## Optimization

Use:

- stop/start scheduling
- smaller dev instance types
- ephemeral workloads

Example:

```text
t3.micro
t3.small
```

for non-production learning environments.

---

# 5. Amazon ECR

## Description

Container image registry.

Stores:

- Docker images
- deployment artifacts

---

## Cost Drivers

- image storage
- stale image accumulation
- large image sizes

---

## Optimization

Implemented:

- lifecycle policy
- automatic cleanup
- immutable tags

Future:

- image size optimization
- multi-stage Docker builds

---

# 6. Terraform Backend

## Components

Remote state:

- S3 bucket
- DynamoDB table

---

## Cost Profile

Very low.

S3:

- state file storage
- version history

DynamoDB:

- lock coordination
- lightweight access pattern

---

## Optimization

Minimal action required.

This cost is negligible compared to operational safety gained.

---

# 7. CI/CD Pipeline Cost

## Components

GitHub Actions:

- workflow execution
- container builds
- scans

Potential AWS usage:

- ECR push
- deployment automation

---

## Optimization

Reduce:

- unnecessary pipeline triggers
- duplicate builds
- excessive scans

Use:

- branch filtering
- conditional workflows
- cache layers

---

# Future Cost Drivers

As project grows, new costs will emerge.

---

## Application Load Balancer

Expected usage:

- ingress traffic routing
- Kubernetes service exposure

Cost factors:

- ALB runtime
- request volume
- LCU consumption

---

## CloudWatch

Usage:

- logs
- metrics
- dashboards
- alarms

Cost risks:

- verbose log retention
- excessive metrics ingestion

Optimization:

- retention policies
- log filtering
- targeted dashboards

---

## Prometheus / Grafana

Cost sources:

- storage
- persistent volumes
- node resource consumption

Optimization:

- retention tuning
- right-sized monitoring stack

---

## Fluent Bit Logging

Risk:

High-volume log ingestion.

Mitigation:

- filtering
- log levels
- retention control

---

## WAF

Expected costs:

- Web ACL
- managed rule groups
- request inspection

Worthwhile for enterprise security showcase.

---

# Estimated Relative Cost Profile

| Component | Cost Level |
|---------|------------|
| EKS Control Plane | High |
| Managed Nodes | Medium–High |
| NAT Gateway | Medium–High |
| EC2 | Medium |
| ALB (future) | Medium |
| CloudWatch | Medium |
| Prometheus/Grafana | Medium |
| ECR | Low |
| S3 Backend | Very Low |
| DynamoDB Locking | Very Low |
| GitHub OIDC | Free |

---

# Cost Optimization Roadmap

## Phase 1

Immediate:

- ECR lifecycle cleanup
- smaller dev compute
- stop idle resources

---

## Phase 2

Networking:

- VPC endpoints
- reduce NAT dependency

---

## Phase 3

Kubernetes:

- HPA
- Cluster Autoscaler
- spot nodes

---

## Phase 4

Monitoring:

- retention tuning
- filtered logging
- targeted alerts

---

## Phase 5

Production Architecture:

- workload rightsizing
- multi-environment cost governance

---

# Cost Governance Best Practices

Recommended controls:

- AWS Budgets
- billing alarms
- Cost Explorer
- tagging strategy
- environment separation

Tag standards:

```text
Environment=dev
Project=aws-enterprise-capstone
Owner=Ashish
ManagedBy=Terraform
```

---

# Cost Monitoring Commands

## EKS

```bash
kubectl top nodes
kubectl top pods -A
```

---

## AWS Cost Explorer

AWS Console:

```text
Billing → Cost Explorer
```

---

## Resource Inventory

```bash
aws ec2 describe-instances --region ap-south-1
```

```bash
aws eks list-clusters --region ap-south-1
```

```bash
aws ecr describe-repositories --region ap-south-1
```

---

# Cost vs Learning Trade-Off

This project intentionally includes premium architecture components for engineering learning value.

Examples:

- EKS instead of ECS
- managed Kubernetes instead of simpler deployment
- Terraform remote backend
- enterprise networking patterns

These choices increase cost modestly but dramatically improve:

- architecture depth
- recruiter impact
- interview storytelling
- real-world engineering relevance

---

# Engineering Decision Summary

This platform prioritizes:

**learning value + engineering realism + enterprise architecture exposure**

over pure minimum-cost experimentation.

Future iterations will optimize aggressively.

---

# Final Recommendation

For production evolution:

Adopt:

- spot node strategy
- autoscaling
- VPC endpoints
- observability retention controls
- workload rightsizing

This creates a cost-efficient enterprise platform.
