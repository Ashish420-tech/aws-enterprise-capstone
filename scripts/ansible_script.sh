#!/bin/bash

set -e

PROJECT_ROOT=~/aws-enterprise-capstone
ANSIBLE_DIR=$PROJECT_ROOT/ansible

echo "======================================"
echo " AWS ENTERPRISE CAPSTONE - ANSIBLE OPS"
echo "======================================"

cd $ANSIBLE_DIR

echo ""
echo "[1] Ansible version"
ansible --version

echo ""
echo "[2] Inventory check"
ansible-inventory --list

echo ""
echo "[3] Syntax check - bootstrap"
ansible-playbook playbooks/bootstrap.yml --syntax-check

echo ""
echo "[4] Syntax check - docker"
ansible-playbook playbooks/docker.yml --syntax-check

echo ""
echo "[5] Syntax check - deploy app"
ansible-playbook playbooks/deploy-app.yml --syntax-check

echo ""
echo "Validation complete."
