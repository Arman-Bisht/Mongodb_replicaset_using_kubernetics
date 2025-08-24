# Installing Docker on Windows

Docker is required to run containers which are the foundation for Kubernetes. Follow these steps to install Docker Desktop on your Windows system:

## System Requirements

- Windows 10 64-bit: Pro, Enterprise, or Education (Build 18362 or later)
- Windows 11 64-bit
- Enable Hyper-V and Containers Windows features
- 64-bit processor with Second Level Address Translation (SLAT)
- 4GB system RAM
- BIOS-level hardware virtualization support must be enabled

## Installation Steps

1. **Download Docker Desktop**
   - Go to [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)
   - Click on "Download for Windows"

2. **Run the Installer**
   - Double-click the downloaded `Docker Desktop Installer.exe` file
   - Follow the installation wizard instructions
   - When prompted, ensure the "Use WSL 2 instead of Hyper-V" option is selected (recommended)

3. **Start Docker Desktop**
   - After installation completes, start Docker Desktop from the Start menu
   - Wait for Docker to start (the whale icon in the taskbar will stop animating when Docker is ready)

4. **Verify Installation**
   - Open PowerShell or Command Prompt
   - Run the following command to verify Docker is installed correctly:
     ```powershell
     docker --version
     ```
   - Test that Docker can pull and run containers:
     ```powershell
     docker run hello-world
     ```

## Troubleshooting

### WSL 2 Installation

If you're using WSL 2 backend and encounter issues, you may need to:

1. Install the WSL 2 Linux kernel update package:
   - Download from [Microsoft WSL2 Kernel](https://docs.microsoft.com/en-us/windows/wsl/install-manual#step-4---download-the-linux-kernel-update-package)
   - Run the installer

2. Set WSL 2 as your default version:
   ```powershell
   wsl --set-default-version 2
   ```

### Hyper-V Issues

If using Hyper-V backend and Docker fails to start:

1. Ensure Hyper-V is enabled:
   - Open "Turn Windows features on or off"
   - Check "Hyper-V" and "Containers" features
   - Restart your computer

2. Check virtualization is enabled in BIOS/UEFI

## Next Steps

Once Docker is successfully installed and running, proceed to installing kubectl and setting up a local Kubernetes cluster.