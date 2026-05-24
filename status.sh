#!/bin/bash

echo "Status checking"


==================================
echo "Dir Creation"
cd ~/aws-enterprise-capstone

mkdir -p terraform/modules/vpc
mkdir -p terraform/environments/dev

touch terraform/modules/vpc/main.tf
touch terraform/modules/vpc/variables.tf
touch terraform/modules/vpc/outputs.tf

touch terraform/environments/dev/main.tf
touch terraform/environments/dev/providers.tf
touch terraform/environments/dev/terraform.tfvars
touch terraform/environments/dev/variables.tf
=============================================
echo " Next level Framework created"

cd ~/aws-enterprise-capstone

mkdir -p \
.github/workflows \
ansible/inventories/dev/group_vars \
ansible/roles/{common,docker,nginx,app}/tasks \
ansible/playbooks \
app/src \
k8s/base \
k8s/ingress \
k8s/helm \
monitoring/cloudwatch \
monitoring/dashboards \
scripts \
docs

touch \
.github/workflows/terraform.yml \
.github/workflows/app-ci.yml \
.github/workflows/deploy.yml \
ansible/inventories/dev/hosts.ini \
ansible/inventories/dev/group_vars/all.yml \
ansible/ansible.cfg \
ansible/playbooks/bootstrap.yml \
ansible/playbooks/docker.yml \
ansible/playbooks/deploy-app.yml \
app/Dockerfile \
app/docker-compose.yml \
app/README.md \
k8s/base/deployment.yaml \
k8s/base/service.yaml \
k8s/base/namespace.yaml \
scripts/destroy.sh \
scripts/deploy.sh \
scripts/validate.sh \
docs/architecture.md \
docs/cost-tracking.md \
docs/runbook.md \
README.md

echo " All created"
tree -a -L 3
