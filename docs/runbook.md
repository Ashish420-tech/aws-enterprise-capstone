# Operations Runbook

## Purpose

Operational procedures for deployment, validation, troubleshooting, and recovery.

---

# Infrastructure Provisioning

## Bootstrap Backend

```bash
cd terraform/bootstrap
terraform init
terraform apply
Provision Platform
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
Validation Commands
AWS

Check VPC:

aws ec2 describe-vpcs --region ap-south-1

Check subnets:

aws ec2 describe-subnets --region ap-south-1

Check EKS:

aws eks list-clusters --region ap-south-1

Check node groups:

aws eks list-nodegroups \
  --cluster-name dev-enterprise-eks \
  --region ap-south-1

Check ECR:

aws ecr describe-repositories --region ap-south-1
Kubernetes Validation

Update kubeconfig:

aws eks update-kubeconfig \
  --region ap-south-1 \
  --name dev-enterprise-eks

Cluster info:

kubectl cluster-info

Nodes:

kubectl get nodes

Pods:

kubectl get pods -A
CI/CD Validation

Workflows:

GitHub → Actions

Validate:

terraform workflow
security scan
deploy pipeline
Troubleshooting
Terraform Backend Lock

Issue:

Error acquiring state lock

Fix:

terraform force-unlock LOCK_ID
EKS Node Join Failure

Check:

aws eks describe-nodegroup \
  --cluster-name dev-enterprise-eks \
  --nodegroup-name dev-node-group \
  --region ap-south-1

Common causes:

subnet routing
IAM permissions
instance quota
unsupported instance type
Kubernetes API Failure

Check:

kubectl cluster-info

Then:

aws eks update-kubeconfig
Docker Push Failure

Validate:

aws ecr get-login-password

Login:

docker login
Recovery

Destroy:

terraform destroy

Backend destroy:

cd terraform/bootstrap
terraform destroy
Monitoring Commands

CPU:

kubectl top nodes

Pods:

kubectl top pods

CloudWatch:

AWS Console → CloudWatch


---

# 3. docs/cost-tracking.md

```markdown
# Cost Tracking & Optimization

## Objective

Track and optimize AWS infrastructure spend.

---

# Major Cost Drivers

## Networking

- NAT Gateway
- public IP
- data transfer

---

## Compute

- EC2
- EKS managed nodes

---

## Storage

- EBS
- S3 backend

---

## Kubernetes

- control plane charges
- worker node compute

---

# Estimated Monthly Cost

| Service | Estimate |
|--------|----------|
| NAT Gateway | Medium |
| EC2 | Medium |
| EKS Control Plane | High |
| EKS Nodes | Medium |
| S3 Backend | Low |
| DynamoDB Locking | Low |
| ECR | Low |

---

# Optimization Strategy

## Compute

Use:

- right-sized nodes
- spot nodes
- autoscaling

---

## Networking

Reduce:

- NAT usage
- idle data transfer

---

## Storage

Use:

- lifecycle policies
- image cleanup

---

## CI/CD

Avoid:

- excessive pipeline runs

---

# Cost Governance

Monitor:

AWS Cost Explorer

CloudWatch billing alarms

---

# Planned Improvements

- spot nodes
- autoscaling
- cost dashboards
- cost anomaly detection
