# Installing Helm on Windows

Helm is a package manager for Kubernetes that helps you define, install, and upgrade applications. This guide will walk you through installing Helm on your Windows system.

## Prerequisites

- Kubernetes cluster set up (Minikube or Kind)
- kubectl installed and configured

## Method 1: Using Chocolatey (Recommended)

1. **Open PowerShell as Administrator**

2. **Install Helm using Chocolatey**
   ```powershell
   choco install kubernetes-helm
   ```

3. **Verify the installation**
   ```powershell
   helm version
   ```

## Method 2: Direct Download

1. **Download the Helm binary**
   - Go to the [Helm Releases page](https://github.com/helm/helm/releases)
   - Download the Windows amd64 version (e.g., `helm-v3.12.0-windows-amd64.zip`)

2. **Extract the zip file**
   ```powershell
   Expand-Archive -Path helm-v3.12.0-windows-amd64.zip -DestinationPath C:\helm
   ```

3. **Add Helm to PATH**
   - Move the helm.exe to a directory in your PATH or add the directory to your PATH:
     - Right-click on 'This PC' or 'My Computer' and click 'Properties'
     - Click on 'Advanced system settings'
     - Click on 'Environment Variables'
     - Under 'System variables', find 'Path', select it and click 'Edit'
     - Click 'New' and add the path to the directory containing helm.exe (e.g., `C:\helm\windows-amd64`)
     - Click 'OK' on all dialogs to save

4. **Verify the installation**
   - Open a new PowerShell window and run:
     ```powershell
     helm version
     ```

## Initialize Helm

1. **Add the stable repository**
   ```powershell
   helm repo add stable https://charts.helm.sh/stable
   ```

2. **Update the repositories**
   ```powershell
   helm repo update
   ```

## Using Helm with MongoDB

While our MongoDB deployment uses raw Kubernetes manifests, Helm can be useful for installing additional components like monitoring tools.

### Installing Prometheus and Grafana using Helm

```powershell
# Add the Prometheus community Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Update repositories
helm repo update

# Install Prometheus Stack (includes Grafana)
helm install monitoring prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
```

### Installing Elasticsearch and Kibana using Helm

```powershell
# Add the Elastic Helm repository
helm repo add elastic https://helm.elastic.co

# Update repositories
helm repo update

# Install Elasticsearch
helm install elasticsearch elastic/elasticsearch --namespace logging --create-namespace

# Install Kibana
helm install kibana elastic/kibana --namespace logging --set service.type=NodePort
```

## Useful Helm Commands

- List installed releases: `helm list --all-namespaces`
- Uninstall a release: `helm uninstall [release-name] -n [namespace]`
- Search for charts: `helm search repo [keyword]`
- Show chart details: `helm show chart [repo/chart]`
- Upgrade a release: `helm upgrade [release-name] [chart] -n [namespace]`

## Next Steps

With Helm installed, you can now easily deploy and manage applications on your Kubernetes cluster. Consider exploring the following optional components for your MongoDB deployment:

1. Configure Prometheus and Grafana for monitoring
2. Set up Elasticsearch and Kibana for logging