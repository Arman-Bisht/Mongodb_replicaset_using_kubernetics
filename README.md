# MongoDB Replica Set on Kubernetes

This project provides a robust MongoDB replica set deployment in a Kubernetes cluster, ensuring high availability and fault tolerance through proper configuration of data replication.

## Features

- **High Availability**: MongoDB replica set with 3 nodes for redundancy and fault tolerance
- **Data Persistence**: Persistent storage using Kubernetes PersistentVolumeClaims
- **Automatic Failover**: Built-in replica set failover mechanism
- **Dynamic Scaling**: Horizontal Pod Autoscaler to adjust replica count based on load
- **Monitoring**: Prometheus integration for metrics collection
- **Logging**: Fluentd for log aggregation to Elasticsearch

## Prerequisites

- Kubernetes cluster (v1.19+)
- kubectl configured to communicate with your cluster
- Storage class capable of provisioning PersistentVolumes

## Deployment

### Automatic Deployment

For Linux/macOS:
```bash
chmod +x deploy.sh
./deploy.sh
```

For Windows:
```powershell
.\deploy.ps1
```

### Manual Deployment

1. Create the storage resources:
   ```bash
   kubectl apply -f k8s/mongodb/mongodb-storage.yaml
   ```

2. Create the ConfigMap with MongoDB configuration:
   ```bash
   kubectl apply -f k8s/mongodb/mongodb-configmap.yaml
   ```

3. Create the MongoDB Services:
   ```bash
   kubectl apply -f k8s/mongodb/mongodb-service.yaml
   ```

4. Deploy the MongoDB StatefulSet:
   ```bash
   kubectl apply -f k8s/mongodb/mongodb-statefulset.yaml
   ```

5. Initialize the MongoDB Replica Set:
   ```bash
   kubectl apply -f k8s/mongodb/mongodb-init-script.yaml
   ```

6. Configure autoscaling:
   ```bash
   kubectl apply -f k8s/mongodb/mongodb-hpa.yaml
   ```

7. Set up monitoring:
   ```bash
   kubectl apply -f k8s/mongodb/mongodb-monitoring.yaml
   ```

8. Set up logging:
   ```bash
   kubectl apply -f k8s/mongodb/mongodb-logging.yaml
   ```

## Verification

Verify that the MongoDB pods are running:
```bash
kubectl get pods -l app=mongodb
```

Verify that the replica set is initialized:
```bash
kubectl exec -it mongodb-0 -- mongo --eval "rs.status()"
```

## Connecting to MongoDB

### From within the Kubernetes cluster

Use the following connection string in your applications:
```
mongodb://mongodb-0.mongodb-headless,mongodb-1.mongodb-headless,mongodb-2.mongodb-headless:27017/?replicaSet=rs0
```

Or connect to the MongoDB service:
```
mongodb://mongodb:27017
```

### From outside the cluster

You can use port forwarding to connect to MongoDB from your local machine:
```bash
kubectl port-forward svc/mongodb 27017:27017
```

Then connect using:
```
mongodb://localhost:27017
```

## Monitoring

The MongoDB exporter collects metrics from MongoDB and exposes them for Prometheus. If you have Grafana set up, you can import MongoDB dashboards for visualization.

## Scaling

The Horizontal Pod Autoscaler will automatically scale the MongoDB StatefulSet based on CPU and memory utilization. You can manually scale the StatefulSet using:

```bash
kubectl scale statefulset mongodb --replicas=5
```

## Backup and Restore

### Backup

You can create a backup of your MongoDB data using:

```bash
kubectl exec mongodb-0 -- mongodump --archive=/tmp/mongodb-backup.gz --gzip --db=your_database
kubectl cp mongodb-0:/tmp/mongodb-backup.gz ./mongodb-backup.gz
```

### Restore

To restore from a backup:

```bash
kubectl cp ./mongodb-backup.gz mongodb-0:/tmp/mongodb-backup.gz
kubectl exec mongodb-0 -- mongorestore --archive=/tmp/mongodb-backup.gz --gzip --db=your_database
```

## Troubleshooting

### Check MongoDB logs

```bash
kubectl logs -f mongodb-0
```

### Check replica set status

```bash
kubectl exec -it mongodb-0 -- mongo --eval "rs.status()"
```

### Check MongoDB metrics

```bash
kubectl port-forward svc/mongodb-exporter 9216:9216
```

Then open http://localhost:9216/metrics in your browser.

## Architecture

This deployment uses the following Kubernetes resources:

- **StatefulSet**: Manages the MongoDB pods with stable network identities
- **ConfigMap**: Stores MongoDB configuration and replica set initialization script
- **Services**: Provides network access to MongoDB pods
- **PersistentVolumeClaims**: Provides persistent storage for MongoDB data
- **HorizontalPodAutoscaler**: Automatically scales MongoDB based on resource utilization
- **Prometheus ServiceMonitor**: Collects MongoDB metrics
- **Fluentd DaemonSet**: Collects and forwards MongoDB logs

## License

This project is licensed under the MIT License - see the LICENSE file for details.