# MongoDB Replica Set on Kubernetes - Tech Stack Installation Guide

This directory contains guides for installing and configuring the necessary tech stack to run a MongoDB replica set in Kubernetes. Follow these guides in sequence to set up your environment.

## Installation Sequence

### Required Components

1. [Docker Installation](./01-docker-installation.md)
   - Container runtime required for Kubernetes and MongoDB containers
   - **Priority**: High

2. [kubectl Installation](./02-kubectl-installation.md)
   - Command-line tool for interacting with Kubernetes clusters
   - **Priority**: High

3. [Minikube/Kind Setup](./03-minikube-setup.md)
   - Local Kubernetes cluster for development and testing
   - **Priority**: High

### Optional Components

4. [Helm Installation](./04-helm-installation.md)
   - Package manager for Kubernetes
   - Simplifies deployment of monitoring and logging stacks
   - **Priority**: Medium

5. [Prometheus and Grafana Setup](./05-prometheus-grafana-setup.md)
   - Monitoring solution for MongoDB metrics
   - **Priority**: Medium

6. [Elasticsearch and Kibana Setup](./06-elasticsearch-kibana-setup.md)
   - Logging solution for MongoDB logs
   - **Priority**: Medium

### Deployment

7. [MongoDB Deployment Guide](./07-deployment-guide.md)
   - Step-by-step instructions for deploying MongoDB after installing the tech stack
   - **Priority**: High

## System Requirements

- **CPU**: Minimum 2 cores, recommended 4+ cores
- **RAM**: Minimum 4GB, recommended 8GB+
- **Disk**: Minimum 20GB free space
- **OS**: Windows 10/11 with WSL2 enabled
- **Network**: Internet connection for downloading components

## Quick Start

For a minimal setup to get started quickly:

1. Install Docker Desktop for Windows
2. Enable Kubernetes in Docker Desktop settings
3. Deploy MongoDB using the provided deployment scripts

```powershell
# Navigate to the project root directory
cd ..

# Run the deployment script
.\deploy.ps1
```

## Verification

After installing all components, verify your setup:

```powershell
# Check Docker
docker version

# Check kubectl
kubectl version

# Check Kubernetes cluster
kubectl cluster-info

# Check Helm (if installed)
helm version
```

## Next Steps

Once you have installed the necessary components, return to the main project directory and follow the instructions in the main README.md file to deploy the MongoDB replica set.

## Troubleshooting

If you encounter issues during installation:

1. Ensure your system meets the minimum requirements
2. Check that Windows features like Hyper-V and WSL2 are properly enabled
3. Refer to the specific installation guide for common issues and solutions
4. For Docker Desktop issues, try resetting to factory defaults in the settings

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)