# Setting Up Prometheus and Grafana for MongoDB Monitoring

This guide will help you set up Prometheus and Grafana to monitor your MongoDB replica set in Kubernetes.

## Prerequisites

- Kubernetes cluster running (Minikube or Kind)
- kubectl installed and configured
- Helm installed (recommended)

## Method 1: Using Helm (Recommended)

The easiest way to deploy Prometheus and Grafana is using the kube-prometheus-stack Helm chart.

### Step 1: Add the Prometheus Community Helm Repository

```powershell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### Step 2: Create a Monitoring Namespace

```powershell
kubectl create namespace monitoring
```

### Step 3: Install the Prometheus Stack

```powershell
helm install monitoring prometheus-community/kube-prometheus-stack --namespace monitoring
```

This chart includes:
- Prometheus server
- Alertmanager
- Grafana
- Node exporter
- kube-state-metrics
- Various Kubernetes service monitors

### Step 4: Access Grafana Dashboard

1. **Forward the Grafana port**
   ```powershell
   kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
   ```

2. **Access Grafana in your browser**
   - Open http://localhost:3000
   - Default credentials:
     - Username: admin
     - Password: prom-operator

## Method 2: Manual Deployment

If you prefer not to use Helm, you can deploy the components manually using the manifests provided in our MongoDB deployment.

### Step 1: Apply the Prometheus Operator Manifests

```powershell
# Create namespace
kubectl create namespace monitoring

# Apply CRDs
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml

# Apply Prometheus Operator
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator.yaml
```

### Step 2: Deploy Prometheus

Create a file named `prometheus.yaml`:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: prometheus
  namespace: monitoring
spec:
  serviceAccountName: prometheus
  serviceMonitorSelector:
    matchLabels:
      app: mongodb
  resources:
    requests:
      memory: 400Mi
  enableAdminAPI: false
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus
  namespace: monitoring
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: monitoring
spec:
  type: ClusterIP
  ports:
  - name: web
    port: 9090
    targetPort: web
  selector:
    prometheus: prometheus
```

Apply the manifest:

```powershell
kubectl apply -f prometheus.yaml
```

### Step 3: Deploy Grafana

Create a file named `grafana.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:latest
        ports:
        - containerPort: 3000
          name: http
        env:
        - name: GF_SECURITY_ADMIN_USER
          value: admin
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: admin
        - name: GF_USERS_ALLOW_SIGN_UP
          value: "false"
        volumeMounts:
        - name: grafana-storage
          mountPath: /var/lib/grafana
      volumes:
      - name: grafana-storage
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: monitoring
spec:
  type: NodePort
  ports:
  - port: 3000
    targetPort: 3000
    nodePort: 30300
  selector:
    app: grafana
```

Apply the manifest:

```powershell
kubectl apply -f grafana.yaml
```

## Configuring MongoDB Monitoring

### Step 1: Apply the MongoDB ServiceMonitor

The MongoDB ServiceMonitor is already included in our deployment in the `mongodb-monitoring.yaml` file. If you haven't applied it yet:

```powershell
kubectl apply -f k8s/mongodb/mongodb-monitoring.yaml
```

### Step 2: Import MongoDB Dashboards in Grafana

1. **Access Grafana** as described above

2. **Add Prometheus as a data source**
   - Go to Configuration > Data Sources
   - Click "Add data source"
   - Select "Prometheus"
   - Set URL to `http://prometheus-operated:9090` (if using Helm) or `http://prometheus:9090` (if manual)
   - Click "Save & Test"

3. **Import MongoDB Dashboard**
   - Go to Create > Import
   - Enter dashboard ID `7362` (Percona MongoDB dashboard)
   - Select your Prometheus data source
   - Click "Import"

## Monitoring MongoDB Metrics

Key MongoDB metrics to monitor:

1. **Replica Set Status**
   - Primary/Secondary status
   - Replication lag

2. **Resource Utilization**
   - CPU usage
   - Memory usage
   - Disk I/O

3. **Database Operations**
   - Operations per second (inserts, updates, deletes, queries)
   - Latency

4. **Connection Metrics**
   - Current connections
   - Connection pool status

## Setting Up Alerts (Optional)

1. **Create a file named `mongodb-alerts.yaml`**:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: mongodb-alerts
  namespace: monitoring
  labels:
    app: mongodb
spec:
  groups:
  - name: mongodb
    rules:
    - alert: MongoDBDown
      expr: mongodb_up == 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "MongoDB instance down"
        description: "MongoDB instance has been down for more than 1 minute."
    - alert: MongoDBReplicationLag
      expr: mongodb_replset_member_optime_date{state="SECONDARY"} - on(set) group_left() mongodb_replset_member_optime_date{state="PRIMARY"} > 10
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "MongoDB replication lag"
        description: "MongoDB replication lag is more than 10 seconds."
```

2. **Apply the alerts**:

```powershell
kubectl apply -f mongodb-alerts.yaml
```

## Next Steps

With Prometheus and Grafana set up, you can now:

1. Set up Elasticsearch and Kibana for logging
2. Deploy your MongoDB replica set using the deployment scripts