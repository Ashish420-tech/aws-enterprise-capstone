# AWS Enterprise DevOps Capstone

> End-to-end production-grade DevOps platform on AWS — built from scratch with IaC, Kubernetes, CI/CD automation, observability, and zero static credentials.

![AWS](https://img.shields.io/badge/AWS-Cloud-orange?logo=amazon-aws) ![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform) ![Kubernetes](https://img.shields.io/badge/Orchestration-EKS-326CE5?logo=kubernetes) ![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=github-actions) ![Security](https://img.shields.io/badge/Security-Hardened-green)

---

## What This Project Demonstrates

| Area | Highlights |
|---|---|
| **Infrastructure** | Fully automated with Terraform — VPC, EKS, IAM, EC2 |
| **CI/CD** | 4-stage GitHub Actions pipeline with OIDC (zero static credentials) |
| **Security** | 12 active controls including Trivy scanning, CloudTrail, and Secrets Manager |
| **Observability** | CloudWatch Container Insights + Fluent Bit + SNS alerting |

---

## Architecture

```
Developer → GitHub → GitHub Actions CI/CD
                         │
            ┌────────────┼────────────┐
            │            │            │
       Terraform CI   App CI    Security Scan
            │            │
            └─── GitHub OIDC (passwordless) ───→ AWS IAM
                                                    │
                    ┌───────────────────────────────┤
                    │                               │
             VPC / Networking                 EKS Cluster
             EC2 (SSM-only)                  Managed Node Group
             IAM / Security Groups                  │
                                           Helm → Flask App
                                           LoadBalancer → Users

Observability:  CloudWatch · Fluent Bit · Container Insights · SNS
Security:       CloudTrail · IAM Access Analyzer · VPC Flow Logs · Secrets Manager · Trivy
```

---

## Technology Stack

| Category | Technology |
|---|---|
| Cloud | AWS |
| Infrastructure as Code | Terraform |
| Configuration Management | Ansible |
| Containers | Docker |
| Registry | Amazon ECR |
| Orchestration | Amazon EKS |
| Packaging | Helm |
| CI/CD | GitHub Actions |
| Authentication | GitHub OIDC (passwordless) |
| Monitoring | CloudWatch Container Insights |
| Log Forwarding | Fluent Bit |
| Alerting | SNS |
| Security Scanning | Trivy |
| Secrets | AWS Secrets Manager |
| Audit | CloudTrail + IAM Access Analyzer + VPC Flow Logs |
| Application | Python Flask |

---

## Implementation Phases

### Phase 1 — Infrastructure as Code (Terraform)

Modular VPC with public/private subnets, NAT gateway, IAM roles with least-privilege, and a private EC2 instance with SSM-only access (no SSH). Solved dependency ordering and IAM propagation race conditions common in large infrastructure graphs.

**Key files:** `terraform/modules/networking/`, `terraform/modules/ec2/`, `terraform/modules/iam/`

---

### Phase 2 — Configuration Management (Ansible)

Automated EC2 bootstrap and application deployment over SSM — no SSH required. Playbooks cover OS hardening, Docker installation, and container lifecycle management. Role-based structure for reuse across environments.

**Key files:** `ansible/playbooks/bootstrap.yml`, `ansible/playbooks/deploy.yml`, `ansible/roles/`

---

### Phase 3 — Containerization (Docker + ECR)

Production Python Flask image with:
- Non-root user execution
- Minimal base image (`python:slim`)
- No privilege escalation
- Pushed to ECR with vulnerability scanning enabled

Trivy-detected CVEs remediated during build pipeline.

**Key files:** `app/Dockerfile`, `app/app.py`

---

### Phase 4 — CI/CD Automation (GitHub Actions)

Four automated pipelines:

| Workflow | Purpose |
|---|---|
| `terraform-ci.yml` | Init, validate, fmt check, plan |
| `app-ci.yml` | Docker build + ECR push |
| `deploy.yml` | OIDC auth → EKS kubeconfig → Helm deploy |
| `security-scan.yml` | Trivy image scan + Trivy IaC scan |

**Key files:** `.github/workflows/`

---

### Phase 5 — Kubernetes / EKS

Managed EKS cluster with OIDC provider. Migrated from raw Kubernetes manifests to Helm for versioned, parameterized, rollback-capable deployments.

Runtime security hardening applied:
- `runAsNonRoot: true`
- `readOnlyRootFilesystem: true`
- Dropped Linux capabilities
- No privilege escalation

**Key files:** `helm/aws-enterprise-capstone/`, `k8s/base/`

---

### Phase 6 — Observability (CloudWatch + SNS)

- Container Insights collecting CPU, memory, node, and pod metrics
- Fluent Bit forwarding container logs to CloudWatch Logs
- Custom CloudWatch dashboard: `enterprise-eks-dashboard`
- Threshold alarms with email delivery via SNS

---

### Phase 7 — Security Hardening

| Control | Details |
|---|---|
| GitHub OIDC Federation | Eliminates all static AWS credentials in CI/CD |
| CloudTrail | Full API audit logging |
| IAM Access Analyzer | Privilege visibility and external access detection |
| VPC Flow Logs | Network traffic audit trail |
| Secrets Manager | Secure runtime secrets, validated from a running pod |
| Trivy | Container and IaC scanning in CI pipeline |

---

## Security Controls

| Control | Status |
|---|---|
| GitHub OIDC Federation | ✅ |
| No Static AWS Credentials | ✅ |
| SSM-only EC2 Access | ✅ |
| Non-root Containers | ✅ |
| Hardened Kubernetes Runtime | ✅ |
| Trivy Image Scanning | ✅ |
| Trivy IaC Scanning | ✅ |
| CloudTrail Audit Logging | ✅ |
| IAM Access Analyzer | ✅ |
| VPC Flow Logs | ✅ |
| Secrets Manager Integration | ✅ |
| ECR Vulnerability Scanning | ✅ |

---

## Repository Structure

```
aws-enterprise-capstone/
├── terraform/                  # Modular IaC: networking, EC2, IAM, security
│   ├── modules/
│   │   ├── networking/
│   │   ├── ec2/
│   │   ├── iam/
│   │   └── security/
│   └── environments/dev/
├── ansible/                    # EC2 configuration and app deployment
│   ├── playbooks/
│   │   ├── bootstrap.yml
│   │   └── deploy.yml
│   └── roles/
│       ├── common/
│       ├── docker/
│       └── app/
├── app/                        # Python Flask app + Dockerfile
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
├── helm/                       # Helm chart for EKS deployment
│   └── aws-enterprise-capstone/
├── k8s/base/                   # Raw Kubernetes base manifests
└── .github/workflows/
    ├── terraform-ci.yml        # IaC quality gates
    ├── app-ci.yml              # Build + push to ECR
    ├── deploy.yml              # OIDC → EKS Helm deploy
    └── security-scan.yml       # Trivy image + IaC scan
```

---

## Key Lessons Learned

- **OIDC over static credentials** — eliminates the #1 source of cloud credential leaks in CI/CD pipelines
- **IaC dependency discipline matters** — explicit resource ordering prevents race conditions at scale
- **Kubernetes security defaults are insufficient** — runtime hardening must be applied explicitly
- **Observability is architecture, not an afterthought** — designing metrics and alerting from day one prevents operational blind spots
- **CI/CD security gates expose real weaknesses** — Trivy scanning surfaced vulnerabilities that manual review missed
- **Secret management must never rely on hardcoded values** — Secrets Manager integration validated end-to-end from a running pod

---

## Teardown Order

To avoid dependency failures during cleanup:

```bash
kubectl delete svc <service-name>          # Remove LoadBalancer first
helm uninstall <release> -n <namespace>    # Uninstall Helm release
kubectl delete namespace <namespace>       # Delete namespace
eksctl delete cluster <cluster-name>      # Delete EKS cluster
aws secretsmanager delete-secret ...      # Delete secrets
terraform destroy                          # Destroy all remaining infra
aws ecr delete-repository ...             # Delete ECR repo
```
