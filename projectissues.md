# AWS Enterprise DevOps Capstone — Project Issues & Resolutions

This document captures the real-world technical issues encountered during the implementation of the AWS Enterprise DevOps Capstone project, including root cause analysis, troubleshooting approach, and final resolution.

---

# 1. Terraform Infrastructure Issues

---

## Issue 1.1 — Resource Dependency Failures

### Problem

Terraform attempted to create dependent AWS resources before prerequisite resources were fully available.

Examples:

- Route table creation before Internet Gateway
- NAT route creation before NAT Gateway readiness
- EC2 provisioning before IAM instance profile availability

### Error Symptoms

Examples:

```bash
DependencyViolation
InvalidRoute.NotFound
InvalidSubnetID.NotFound
Root Cause

Terraform resource dependency graph was insufficient for some asynchronous AWS operations.

AWS often accepts API requests before backend resource propagation completes.

Resolution

Added explicit dependencies:

depends_on = [...]

Validated ordering with:

terraform plan
terraform graph
Lesson Learned

AWS infrastructure provisioning is eventually consistent. Explicit dependencies improve reliability.

Issue 1.2 — NAT Gateway Provisioning Delay
Problem

Terraform apply appeared stalled for extended periods.

Root Cause

NAT Gateway provisioning is slow due to:

Elastic IP allocation
ENI attachment
AWS backend propagation
Resolution

Allowed provisioning to complete instead of interrupting.

Lesson Learned

NAT creation delays are expected in AWS.

Issue 1.3 — Route Table Misconfiguration
Problem

Private subnet instances lacked outbound internet connectivity.

Root Cause

Incorrect route association.

Traffic was not routed through NAT Gateway.

Resolution

Corrected:

route table associations
private route configuration

Validation:

aws ec2 describe-route-tables
Lesson Learned

Routing validation is critical in VPC design.

2. Ansible Issues
Issue 2.1 — SSM Instead of SSH Execution Complexity
Problem

Traditional SSH-based Ansible execution was unavailable.

Environment intentionally used:

no public SSH
hardened access
SSM-only management
Root Cause

Enterprise security architecture prohibited SSH access.

Resolution

Configured:

community.aws.aws_ssm

for remote execution.

Validation:

ansible all -m ping
Lesson Learned

SSM provides secure enterprise administration without exposed SSH.

Issue 2.2 — Package Manager Mismatch
Problem

Ansible tasks failed due to incorrect package manager module usage.

Example:

Ubuntu modules used against Amazon Linux.

Error Symptoms
Unsupported parameters
Root Cause

OS-specific module assumptions.

Resolution

Adjusted tasks to correct package manager:

apt
yum
dnf

depending on host OS.

Lesson Learned

Automation must account for target platform differences.

Issue 2.3 — Docker Installation Failures
Problem

Docker service installation/configuration inconsistencies.

Root Cause

Repository package availability differences.

Resolution

Updated installation tasks and service enablement logic.

Validation:

docker --version
systemctl status docker
3. Docker Issues
Issue 3.1 — Dockerfile Path Error
Problem

Container build failed.

Error
failed to read dockerfile
Root Cause

Build executed from incorrect project path.

Dockerfile located in:

app/Dockerfile

not project root.

Resolution

Correct build context:

docker build ./app
Lesson Learned

Docker build context matters.

Issue 3.2 — Running as Root
Problem

Trivy security scan flagged container runtime risk.

Finding
Container running as root
Root Cause

Dockerfile lacked non-root user definition.

Resolution

Added:

RUN useradd ...
USER appuser
Lesson Learned

Containers should never run as root in enterprise production.

Issue 3.3 — Python Dependency Vulnerabilities
Problem

Trivy image scan failed.

Findings
jaraco.context
wheel

HIGH vulnerabilities.

Root Cause

Outdated Python package metadata.

Resolution
upgraded dependencies
refined image scan scope
Lesson Learned

Dependency hygiene is continuous.

4. Amazon ECR Issues
Issue 4.1 — Authentication Failures
Problem

Docker push failed.

Error
no basic auth credentials
Root Cause

Missing ECR login session.

Resolution

Authenticated using:

aws ecr get-login-password
Lesson Learned

ECR authentication must precede push operations.

Issue 4.2 — Tagging Mistakes
Problem

Push failed due to incorrect image naming.

Root Cause

Improper repository tagging.

Resolution

Correct tag:

ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/repo:latest
5. GitHub Actions CI/CD Issues
Issue 5.1 — Invalid Trivy Action Version
Problem

Workflow failed immediately.

Error
unable to find version
Root Cause

Nonexistent action version reference.

Resolution

Updated workflow action reference.

Lesson Learned

Always validate GitHub Action versions.

Issue 5.2 — OIDC Authentication Failure
Problem

Security workflow failed.

Error
Could not load credentials
Root Cause

Missing workflow permission:

id-token: write

required for GitHub OIDC federation.

Resolution

Added required permission.

Lesson Learned

OIDC requires explicit token permissions.

Issue 5.3 — SARIF Upload Failure
Problem

Security workflow failed after successful scan.

Error
Resource not accessible by integration
Root Cause

GitHub code scanning upload permission limitation.

Resolution

Removed SARIF upload dependency.

Lesson Learned

Not all GitHub repos support identical security integrations.

Issue 5.4 — Trivy IaC Findings
Problem

Pipeline failed due to HIGH/CRITICAL findings.

Findings Included
Dockerfile hardening issues
Kubernetes security context gaps
Terraform security findings
Resolution

Remediated:

non-root containers
readOnlyRootFilesystem
capability drops
privilege escalation prevention
Lesson Learned

Security gates reveal real production weaknesses.

Issue 5.5 — App CI Overwriting Manual Images
Problem

Manual local fixes did not affect CI scan results.

Root Cause

App CI rebuilt and pushed repository state.

Resolution

Committed fixes to source repository.

Lesson Learned

CI/CD pipelines are source-of-truth, not local workstations.

6. Kubernetes / EKS Issues
Issue 6.1 — EKS Authentication Failures
Problem

kubectl access denied.

Root Cause

IAM role lacked EKS cluster access permissions.

Resolution

Configured:

EKS access entry
cluster admin access policy

Validation:

kubectl get nodes
Lesson Learned

EKS IAM access must be explicitly granted.

Issue 6.2 — LoadBalancer Provisioning Delay
Problem

Service external endpoint unavailable.

Root Cause

AWS ELB provisioning latency.

Resolution

Waited for service provisioning.

Validation:

kubectl get svc
Lesson Learned

Cloud load balancers provision asynchronously.

Issue 6.3 — Deployment Rollout Failures
Problem

Application rollout instability.

Root Cause

Readiness issues and deployment validation gaps.

Resolution

Added rollout verification:

kubectl rollout status
7. Observability Issues
Issue 7.1 — CloudWatch Metrics Delay
Problem

Dashboards initially empty.

Root Cause

Metrics ingestion delay.

Resolution

Allowed CloudWatch propagation time.

Lesson Learned

Monitoring systems are eventually consistent.

Issue 7.2 — Dashboard Validation
Problem

Widgets appeared incomplete.

Root Cause

Metrics namespace/data delay.

Resolution

Revalidated after metrics stabilized.

8. Security Issues
Issue 8.1 — IAM Policy Propagation Delay
Problem

Secrets Manager access initially failed.

Root Cause

New IAM policy attachment propagation delay.

Resolution

Retested after propagation.

Validation:

aws sts get-caller-identity
Issue 8.2 — Kubernetes Secret Test Pod Failure
Problem

Initial validation pod terminated unexpectedly.

Root Cause

Transient execution/runtime behavior.

Resolution

Revalidated using pod logs.

Successful confirmation:

assumed node IAM role
accessed Secrets Manager
retrieved secret
Issue 8.3 — Container Hardening Findings
Problem

Security scan flagged:

root container execution
writable filesystem
privilege escalation risks
Resolution

Implemented:

USER appuser
readOnlyRootFilesystem
allowPrivilegeEscalation: false
dropped Linux capabilities
9. Architecture Design Tradeoffs
Tradeoff 1 — Public LoadBalancer
Concern

Security scans flagged public exposure patterns.

Decision

Retained public ingress for demonstration access.

Justification

Required for browser validation.

Tradeoff 2 — Broad Egress Rules
Concern

Security scanner flagged unrestricted outbound traffic.

Decision

Accepted for capstone simplicity.

Enterprise Alternative

Restrict egress by destination.

Final Summary

Total categories resolved:

Terraform
Ansible
Docker
ECR
CI/CD
GitHub OIDC
Kubernetes
EKS
CloudWatch
Security scanning
Secrets Manager

This project intentionally surfaced real enterprise engineering problems and resolved them through iterative debugging and production-grade remediation.
