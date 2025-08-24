# Setting Up a Local Kubernetes Cluster with Minikube

Minikube is a tool that lets you run Kubernetes locally. This guide will help you set up Minikube on your Windows system.

## Prerequisites

- Docker installed (see 01-docker-installation.md)
- kubectl installed (see 02-kubectl-installation.md)
- At least 2 CPUs and 2GB of free memory
- Internet connection for the initial download

## Installing Minikube

### Method 1: Using Chocolatey (Recommended)

1. **Open PowerShell as Administrator**

2. **Install Minikube using Chocolatey**
   ```powershell
   choco install minikube
   ```

### Method 2: Direct Download

1. **Download the Minikube installer**
   - Download the latest release from [Minikube Releases](https://github.com/kubernetes/minikube/releases)
   - Look for `minikube-installer.exe` for Windows

2. **Run the installer**
   - Double-click the downloaded installer and follow the prompts

## Starting Minikube

1. **Start Minikube with Docker driver**
   ```powershell
   minikube start --driver=docker
   ```

   This command will:
   - Download the Minikube ISO if it's not already downloaded
   - Create a virtual machine
   - Configure kubectl to use the Minikube cluster

2. **Verify Minikube is running**
   ```powershell
   minikube status
   ```

   You should see output indicating that Minikube is running.

## Configuring Minikube Resources (Optional)

If you need more resources for your MongoDB deployment:

```powershell
minikube stop
minikube start --driver=docker --cpus=4 --memory=8g --disk-size=20g
```

Adjust the values as needed based on your system capabilities.

## Using Minikube

1. **Verify kubectl is configured to use Minikube**
   ```powershell
   kubectl config current-context
   ```
   This should return `minikube`.

2. **Check cluster info**
   ```powershell
   kubectl cluster-info
   ```

3. **Enable necessary addons**
   ```powershell
   minikube addons enable storage-provisioner
   minikube addons enable metrics-server
   ```

## Alternative: Using Kind (Kubernetes in Docker)

If you prefer using Kind instead of Minikube:

1. **Install Kind**
   ```powershell
   choco install kind
   ```

2. **Create a Kind cluster**
   ```powershell
   kind create cluster --name mongodb-cluster
   ```

3. **Verify the cluster**
   ```powershell
   kubectl cluster-info --context kind-mongodb-cluster
   ```

## Next Steps

Now that you have a local Kubernetes cluster running, you can proceed to:

1. Install Helm (optional but recommended)
2. Deploy the MongoDB replica set using the deployment scripts

## Troubleshooting

### Common Issues

1. **Minikube fails to start**
   - Ensure Docker is running
   - Try with a different driver: `minikube start --driver=hyperv`
   - Increase the resources: `minikube start --memory=4096 --cpus=2`

2. **Connection issues**
   - Reset the Minikube cluster: `minikube delete && minikube start`

3. **Docker driver issues**
   - Ensure your user is in the docker-users group
   - Try running PowerShell as Administrator

### Useful Commands

- Stop Minikube: `minikube stop`
- Delete Minikube cluster: `minikube delete`
- Open Minikube dashboard: `minikube dashboard`