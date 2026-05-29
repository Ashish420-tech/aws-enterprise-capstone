Date:
Phase:
Objective:

Steps Completed:
1. Created jenkins namespace
2. Added Jenkins Helm repository
3. Updated Helm repositories

Commands Used:
kubectl create namespace jenkins
helm repo add jenkins https://charts.jenkins.io
helm repo update

Learning:
- Namespace isolates workloads
- Helm repository stores charts
- Jenkins will be deployed into its own namespace
