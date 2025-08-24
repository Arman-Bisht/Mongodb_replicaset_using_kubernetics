# PowerShell script to deploy MongoDB Replica Set to Kubernetes

$ErrorActionPreference = "Stop"

Write-Host "Deploying MongoDB Replica Set to Kubernetes..." -ForegroundColor Green

# Create namespace if it doesn't exist
Write-Host "Creating namespace..." -ForegroundColor Cyan
kubectl create namespace mongodb --dry-run=client -o yaml | kubectl apply -f -

# Apply storage resources
Write-Host "Applying storage resources..." -ForegroundColor Cyan
kubectl apply -f k8s/mongodb/mongodb-storage.yaml

# Apply ConfigMap
Write-Host "Applying ConfigMap..." -ForegroundColor Cyan
kubectl apply -f k8s/mongodb/mongodb-configmap.yaml

# Apply Services
Write-Host "Applying Services..." -ForegroundColor Cyan
kubectl apply -f k8s/mongodb/mongodb-service.yaml

# Apply StatefulSet
Write-Host "Applying StatefulSet..." -ForegroundColor Cyan
kubectl apply -f k8s/mongodb/mongodb-statefulset.yaml

# Wait for StatefulSet to be ready
Write-Host "Waiting for StatefulSet to be ready..." -ForegroundColor Cyan
kubectl rollout status statefulset/mongodb --timeout=5m

# Apply Replica Set Initialization Job
Write-Host "Initializing MongoDB Replica Set..." -ForegroundColor Cyan
kubectl apply -f k8s/mongodb/mongodb-init-script.yaml

# Apply HPA
Write-Host "Applying Horizontal Pod Autoscaler..." -ForegroundColor Cyan
kubectl apply -f k8s/mongodb/mongodb-hpa.yaml

# Apply Monitoring
Write-Host "Applying Monitoring resources..." -ForegroundColor Cyan
kubectl apply -f k8s/mongodb/mongodb-monitoring.yaml

# Apply Logging
Write-Host "Applying Logging resources..." -ForegroundColor Cyan
kubectl apply -f k8s/mongodb/mongodb-logging.yaml

Write-Host "MongoDB Replica Set deployment completed successfully!" -ForegroundColor Green
Write-Host "To check the status of your deployment, run: kubectl get pods -l app=mongodb" -ForegroundColor Yellow
Write-Host "To connect to MongoDB, run: kubectl exec -it mongodb-0 -- mongo" -ForegroundColor Yellow