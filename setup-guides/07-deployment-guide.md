# Deploying MongoDB Replica Set on Kubernetes

This guide will walk you through the process of deploying the MongoDB replica set on your Kubernetes cluster after you've installed all the necessary tech stack components.

## Prerequisites

Ensure you have completed the following installations:

1. Docker (required)
2. kubectl (required)
3. Local Kubernetes cluster - Minikube or Kind (required)
4. Helm (optional but recommended)
5. Prometheus and Grafana (optional for monitoring)
6. Elasticsearch and Kibana (optional for logging)

## Deployment Steps

### Step 1: Verify Your Kubernetes Cluster

Before deploying, ensure your Kubernetes cluster is running properly:

```powershell
# Check cluster status
kubectl cluster-info

# Check available nodes
kubectl get nodes
```

Your output should show that the cluster is running and at least one node is available with status "Ready".

### Step 2: Deploy MongoDB Using Deployment Scripts

#### Option 1: Using PowerShell Script (Windows)

```powershell
# Navigate to the project root directory
cd ..

# Run the deployment script
.\deploy.ps1
```

#### Option 2: Using Bash Script (Linux/macOS or WSL on Windows)

```bash
# Navigate to the project root directory
cd ..

# Make the script executable (if needed)
chmod +x ./deploy.sh

# Run the deployment script
./deploy.sh
```

### Step 3: Manual Deployment (Alternative)

If you prefer to deploy components individually or if the scripts don't work for your environment:

```powershell
# Create namespace
kubectl create namespace mongodb

# Apply storage configuration
kubectl apply -f ../k8s/mongodb/mongodb-storage.yaml

# Apply ConfigMap
kubectl apply -f ../k8s/mongodb/mongodb-configmap.yaml

# Apply Services
kubectl apply -f ../k8s/mongodb/mongodb-service.yaml

# Deploy StatefulSet
kubectl apply -f ../k8s/mongodb/mongodb-statefulset.yaml

# Wait for StatefulSet to be ready
kubectl rollout status statefulset/mongodb -n mongodb

# Initialize replica set
kubectl apply -f ../k8s/mongodb/mongodb-init-script.yaml

# Apply HPA
kubectl apply -f ../k8s/mongodb/mongodb-hpa.yaml

# Apply monitoring (if Prometheus is installed)
kubectl apply -f ../k8s/mongodb/mongodb-monitoring.yaml

# Apply logging (if Elasticsearch is installed)
kubectl apply -f ../k8s/mongodb/mongodb-logging.yaml
```

## Verification

### Step 1: Check Deployment Status

```powershell
# Check StatefulSet status
kubectl get statefulset -n mongodb

# Check pods
kubectl get pods -n mongodb

# Check services
kubectl get svc -n mongodb
```

You should see:
- A StatefulSet named "mongodb" with the desired number of replicas
- Pods named "mongodb-0", "mongodb-1", "mongodb-2", etc. with status "Running"
- Services named "mongodb" and "mongodb-headless"

### Step 2: Verify Replica Set Configuration

```powershell
# Check replica set status
kubectl exec -it mongodb-0 -n mongodb -- mongosh --eval "rs.status()"
```

You should see output showing the replica set configuration with one primary and multiple secondary nodes.

## Connecting to MongoDB

### From within the Kubernetes cluster

Applications running inside the Kubernetes cluster can connect using:

```
mongodb://mongodb-0.mongodb-headless.mongodb.svc.cluster.local:27017,mongodb-1.mongodb-headless.mongodb.svc.cluster.local:27017,mongodb-2.mongodb-headless.mongodb.svc.cluster.local:27017/dbname?replicaSet=rs0
```

### From your local machine

Set up port forwarding to access MongoDB from your local machine:

```powershell
kubectl port-forward svc/mongodb -n mongodb 27017:27017
```

Then connect using:

```
mongodb://localhost:27017/dbname?replicaSet=rs0
```

You can use MongoDB Compass or another MongoDB client to connect to this URL.

## Accessing Monitoring and Logging

### Prometheus and Grafana (if installed)

```powershell
# Port forward Grafana
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80
```

Open http://localhost:3000 in your browser (default credentials: admin/prom-operator).

### Elasticsearch and Kibana (if installed)

```powershell
# Port forward Kibana
kubectl port-forward svc/kibana -n logging 5601:5601
```

Open http://localhost:5601 in your browser.

## Common Operations

### Scaling the Replica Set

To manually scale the number of replicas:

```powershell
kubectl scale statefulset mongodb -n mongodb --replicas=5
```

### Checking Logs

```powershell
# View logs for a specific pod
kubectl logs mongodb-0 -n mongodb
```

### Accessing MongoDB Shell

```powershell
kubectl exec -it mongodb-0 -n mongodb -- mongosh
```

## Troubleshooting

### Pods Not Starting

Check for persistent volume issues:

```powershell
kubectl get pvc -n mongodb
kubectl describe pvc mongodb-data-mongodb-0 -n mongodb
```

### Replica Set Initialization Fails

Check the initialization job logs:

```powershell
kubectl get jobs -n mongodb
kubectl logs job/mongodb-init -n mongodb
```

### Connection Issues

Verify network connectivity:

```powershell
# Test connection from another pod
kubectl run -it --rm debug --image=mongo:5.0 --restart=Never -n mongodb -- mongosh mongodb://mongodb-0.mongodb-headless:27017
```

## Cleanup

To remove the MongoDB deployment:

```powershell
# Delete all resources in the mongodb namespace
kubectl delete namespace mongodb
```

## Next Steps

Now that you have successfully deployed MongoDB, you can:

1. Create databases and collections
2. Configure authentication and authorization
3. Set up backup and restore procedures
4. Integrate with your applications