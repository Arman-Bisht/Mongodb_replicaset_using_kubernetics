# Setting Up Elasticsearch and Kibana for MongoDB Logging

This guide will help you set up Elasticsearch and Kibana to collect and visualize logs from your MongoDB replica set in Kubernetes.

## Prerequisites

- Kubernetes cluster running (Minikube or Kind)
- kubectl installed and configured
- Helm installed (recommended)

## Method 1: Using Helm (Recommended)

The easiest way to deploy Elasticsearch and Kibana is using the official Elastic Helm charts.

### Step 1: Add the Elastic Helm Repository

```powershell
helm repo add elastic https://helm.elastic.co
helm repo update
```

### Step 2: Create a Logging Namespace

```powershell
kubectl create namespace logging
```

### Step 3: Install Elasticsearch

```powershell
helm install elasticsearch elastic/elasticsearch --namespace logging \
  --set replicas=1 \
  --set minimumMasterNodes=1 \
  --set resources.requests.cpu=100m \
  --set resources.requests.memory=512M \
  --set resources.limits.cpu=1000m \
  --set resources.limits.memory=1Gi
```

For a development environment, we're using minimal resources. For production, you would want to increase these values.

### Step 4: Install Kibana

```powershell
helm install kibana elastic/kibana --namespace logging \
  --set service.type=NodePort \
  --set service.nodePort=30601
```

### Step 5: Install Fluentd

Create a file named `fluentd-values.yaml`:

```yaml
image:
  repository: fluent/fluentd-kubernetes-daemonset
  tag: v1.14-debian-elasticsearch7-1

output:
  host: elasticsearch-master
  port: 9200
  scheme: http

filterSelector:
  matchLabels:
    app: mongodb
```

Install Fluentd:

```powershell
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install fluentd bitnami/fluentd --namespace logging -f fluentd-values.yaml
```

## Method 2: Manual Deployment

If you prefer not to use Helm, you can deploy the components manually.

### Step 1: Deploy Elasticsearch

Create a file named `elasticsearch.yaml`:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: elasticsearch
  namespace: logging
spec:
  serviceName: elasticsearch
  replicas: 1
  selector:
    matchLabels:
      app: elasticsearch
  template:
    metadata:
      labels:
        app: elasticsearch
    spec:
      containers:
      - name: elasticsearch
        image: docker.elastic.co/elasticsearch/elasticsearch:7.17.0
        env:
        - name: discovery.type
          value: single-node
        - name: ES_JAVA_OPTS
          value: "-Xms512m -Xmx512m"
        ports:
        - containerPort: 9200
          name: http
        - containerPort: 9300
          name: transport
        volumeMounts:
        - name: data
          mountPath: /usr/share/elasticsearch/data
        resources:
          limits:
            cpu: 1000m
            memory: 1Gi
          requests:
            cpu: 100m
            memory: 512Mi
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 5Gi
---
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch
  namespace: logging
spec:
  selector:
    app: elasticsearch
  ports:
  - port: 9200
    name: http
  - port: 9300
    name: transport
```

Apply the manifest:

```powershell
kubectl apply -f elasticsearch.yaml
```

### Step 2: Deploy Kibana

Create a file named `kibana.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kibana
  namespace: logging
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kibana
  template:
    metadata:
      labels:
        app: kibana
    spec:
      containers:
      - name: kibana
        image: docker.elastic.co/kibana/kibana:7.17.0
        env:
        - name: ELASTICSEARCH_HOSTS
          value: http://elasticsearch:9200
        ports:
        - containerPort: 5601
        resources:
          limits:
            cpu: 1000m
            memory: 1Gi
          requests:
            cpu: 100m
            memory: 512Mi
---
apiVersion: v1
kind: Service
metadata:
  name: kibana
  namespace: logging
spec:
  type: NodePort
  selector:
    app: kibana
  ports:
  - port: 5601
    targetPort: 5601
    nodePort: 30601
```

Apply the manifest:

```powershell
kubectl apply -f kibana.yaml
```

### Step 3: Deploy Fluentd

The Fluentd configuration is already included in our deployment in the `mongodb-logging.yaml` file. If you haven't applied it yet:

```powershell
kubectl apply -f k8s/mongodb/mongodb-logging.yaml
```

## Accessing Kibana

1. **Access Kibana Dashboard**
   - If using Minikube: `minikube service kibana -n logging`
   - If using NodePort: Open http://localhost:30601 (or your node IP with port 30601)

2. **Configure Index Pattern**
   - In Kibana, go to Management > Stack Management > Kibana > Index Patterns
   - Create a new index pattern with `logstash-*`
   - Select `@timestamp` as the time field
   - Click "Create index pattern"

3. **View MongoDB Logs**
   - Go to Discover
   - Select your index pattern
   - Filter for MongoDB logs with `kubernetes.labels.app: mongodb`

## Creating Kibana Dashboards for MongoDB

1. **Create a new dashboard**
   - Go to Dashboard > Create dashboard

2. **Add visualizations**
   - Click "Create visualization"
   - Create useful visualizations such as:
     - Count of log entries over time
     - Log levels distribution (pie chart)
     - Top error messages (data table)
     - Connection events timeline

3. **Save your dashboard**

## Example Kibana Queries for MongoDB

- Find connection errors: `message:*connection* AND log_level:ERROR`
- Monitor replica set status changes: `message:*replica*set* AND log_level:INFO`
- Track authentication attempts: `message:*auth* OR message:*authenticate*`

## Configuring Log Retention

To manage log storage, create an Index Lifecycle Policy:

1. In Kibana, go to Management > Stack Management > Index Lifecycle Policies
2. Create a new policy
3. Configure phases (hot, warm, cold, delete) based on your retention needs
4. Apply the policy to your indices

## Next Steps

With Elasticsearch and Kibana set up, you can now:

1. Deploy your MongoDB replica set using the deployment scripts
2. Configure more advanced log parsing for MongoDB specific logs
3. Set up alerts based on log patterns