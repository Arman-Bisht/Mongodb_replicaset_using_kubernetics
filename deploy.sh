#!/bin/bash

set -e

echo "Deploying MongoDB Replica Set to Kubernetes..."

# Create namespace if it doesn't exist
kubectl create namespace mongodb --dry-run=client -o yaml | kubectl apply -f -

# Apply storage resources
echo "Applying storage resources..."
kubectl apply -f k8s/mongodb/mongodb-storage.yaml

# Apply ConfigMap
echo "Applying ConfigMap..."
kubectl apply -f k8s/mongodb/mongodb-configmap.yaml

# Apply Services
echo "Applying Services..."
kubectl apply -f k8s/mongodb/mongodb-service.yaml

# Apply StatefulSet
echo "Applying StatefulSet..."
kubectl apply -f k8s/mongodb/mongodb-statefulset.yaml

# Wait for StatefulSet to be ready
echo "Waiting for StatefulSet to be ready..."
kubectl rollout status statefulset/mongodb --timeout=5m

# Apply Replica Set Initialization Job
echo "Initializing MongoDB Replica Set..."
kubectl apply -f k8s/mongodb/mongodb-init-script.yaml

# Apply HPA
echo "Applying Horizontal Pod Autoscaler..."
kubectl apply -f k8s/mongodb/mongodb-hpa.yaml

# Apply Monitoring
echo "Applying Monitoring resources..."
kubectl apply -f k8s/mongodb/mongodb-monitoring.yaml

# Apply Logging
echo "Applying Logging resources..."
kubectl apply -f k8s/mongodb/mongodb-logging.yaml

echo "MongoDB Replica Set deployment completed successfully!"
echo "To check the status of your deployment, run: kubectl get pods -l app=mongodb"
echo "To connect to MongoDB, run: kubectl exec -it mongodb-0 -- mongo"