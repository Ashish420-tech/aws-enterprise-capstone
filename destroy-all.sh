#!/bin/bash
set -e

REGION="ap-south-1"

echo "======================================"
echo " AWS FULL CLEANUP - REGION: $REGION"
echo "======================================"

# -----------------------------
# EKS
# -----------------------------
echo "[1] Deleting EKS clusters..."
CLUSTERS=$(aws eks list-clusters --region $REGION --query 'clusters[]' --output text || true)
for CLUSTER in $CLUSTERS; do
    echo "Deleting EKS cluster: $CLUSTER"
    eksctl delete cluster --name "$CLUSTER" --region $REGION || \
    aws eks delete-cluster --name "$CLUSTER" --region $REGION || true
done

# -----------------------------
# ECS
# -----------------------------
echo "[2] Deleting ECS clusters/services..."
CLUSTERS=$(aws ecs list-clusters --region $REGION --query 'clusterArns[]' --output text || true)
for CL in $CLUSTERS; do
    SERVICES=$(aws ecs list-services --cluster "$CL" --region $REGION --query 'serviceArns[]' --output text || true)
    for SVC in $SERVICES; do
        aws ecs update-service --cluster "$CL" --service "$SVC" --desired-count 0 --region $REGION || true
        aws ecs delete-service --cluster "$CL" --service "$SVC" --force --region $REGION || true
    done
    aws ecs delete-cluster --cluster "$CL" --region $REGION || true
done

# -----------------------------
# EC2
# -----------------------------
echo "[3] Terminating EC2 instances..."
INSTANCES=$(aws ec2 describe-instances \
  --region $REGION \
  --filters Name=instance-state-name,Values=running,stopped,pending,stopping \
  --query 'Reservations[].Instances[].InstanceId' \
  --output text || true)

if [ ! -z "$INSTANCES" ]; then
    aws ec2 terminate-instances --instance-ids $INSTANCES --region $REGION || true
fi

# -----------------------------
# Auto Scaling
# -----------------------------
echo "[4] Deleting Auto Scaling groups..."
ASGS=$(aws autoscaling describe-auto-scaling-groups \
  --region $REGION \
  --query 'AutoScalingGroups[].AutoScalingGroupName' \
  --output text || true)

for ASG in $ASGS; do
    aws autoscaling update-auto-scaling-group \
      --auto-scaling-group-name "$ASG" \
      --min-size 0 \
      --max-size 0 \
      --desired-capacity 0 \
      --region $REGION || true

    aws autoscaling delete-auto-scaling-group \
      --auto-scaling-group-name "$ASG" \
      --force-delete \
      --region $REGION || true
done

# -----------------------------
# Load Balancers
# -----------------------------
echo "[5] Deleting ELBv2..."
LBS=$(aws elbv2 describe-load-balancers \
  --region $REGION \
  --query 'LoadBalancers[].LoadBalancerArn' \
  --output text || true)

for LB in $LBS; do
    aws elbv2 delete-load-balancer --load-balancer-arn "$LB" || true
done

echo "[6] Deleting Classic ELBs..."
CLASSIC=$(aws elb describe-load-balancers \
  --region $REGION \
  --query 'LoadBalancerDescriptions[].LoadBalancerName' \
  --output text || true)

for LB in $CLASSIC; do
    aws elb delete-load-balancer --load-balancer-name "$LB" --region $REGION || true
done

# -----------------------------
# NAT Gateways
# -----------------------------
echo "[7] Deleting NAT gateways..."
NATS=$(aws ec2 describe-nat-gateways \
  --region $REGION \
  --query 'NatGateways[?State!=`deleted`].NatGatewayId' \
  --output text || true)

for NAT in $NATS; do
    aws ec2 delete-nat-gateway --nat-gateway-id "$NAT" --region $REGION || true
done

# -----------------------------
# Elastic IP
# -----------------------------
echo "[8] Releasing Elastic IPs..."
EIPS=$(aws ec2 describe-addresses \
  --region $REGION \
  --query 'Addresses[].AllocationId' \
  --output text || true)

for EIP in $EIPS; do
    aws ec2 release-address --allocation-id "$EIP" --region $REGION || true
done

# -----------------------------
# EBS
# -----------------------------
echo "[9] Deleting EBS volumes..."
VOLUMES=$(aws ec2 describe-volumes \
  --region $REGION \
  --filters Name=status,Values=available \
  --query 'Volumes[].VolumeId' \
  --output text || true)

for VOL in $VOLUMES; do
    aws ec2 delete-volume --volume-id "$VOL" --region $REGION || true
done

# -----------------------------
# ECR
# -----------------------------
echo "[10] Deleting ECR repositories..."
REPOS=$(aws ecr describe-repositories \
  --region $REGION \
  --query 'repositories[].repositoryName' \
  --output text || true)

for REPO in $REPOS; do
    aws ecr delete-repository \
      --repository-name "$REPO" \
      --force \
      --region $REGION || true
done

# -----------------------------
# CloudFormation
# -----------------------------
echo "[11] Deleting CloudFormation stacks..."
STACKS=$(aws cloudformation list-stacks \
  --region $REGION \
  --query 'StackSummaries[?StackStatus!=`DELETE_COMPLETE`].StackName' \
  --output text || true)

for STACK in $STACKS; do
    aws cloudformation delete-stack \
      --stack-name "$STACK" \
      --region $REGION || true
done

# -----------------------------
# CloudWatch Dashboards
# -----------------------------
echo "[12] Deleting CloudWatch dashboards..."
DASH=$(aws cloudwatch list-dashboards \
  --region $REGION \
  --query 'DashboardEntries[].DashboardName' \
  --output text || true)

if [ ! -z "$DASH" ]; then
    aws cloudwatch delete-dashboards \
      --dashboard-names $DASH \
      --region $REGION || true
fi

# -----------------------------
# Lambda
# -----------------------------
echo "[13] Deleting Lambda functions..."
FUNCS=$(aws lambda list-functions \
  --region $REGION \
  --query 'Functions[].FunctionName' \
  --output text || true)

for FN in $FUNCS; do
    aws lambda delete-function \
      --function-name "$FN" \
      --region $REGION || true
done

# -----------------------------
# RDS
# -----------------------------
echo "[14] Deleting RDS..."
DBS=$(aws rds describe-db-instances \
  --region $REGION \
  --query 'DBInstances[].DBInstanceIdentifier' \
  --output text || true)

for DB in $DBS; do
    aws rds delete-db-instance \
      --db-instance-identifier "$DB" \
      --skip-final-snapshot \
      --delete-automated-backups \
      --region $REGION || true
done

echo "======================================"
echo " CLEANUP INITIATED"
echo "======================================"
