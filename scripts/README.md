# Kubeadm Cluster Setup Scripts

## Overview

These scripts automate the setup of a Kubernetes cluster using kubeadm with containerd as the container runtime.

## Components & Versions

- **Kubernetes**: v1.34
- **Container Runtime**: containerd v2.2.0
- **runc**: v1.3.3
- **CNI Plugins**: v1.6.0 (optional, commented out - Calico provides its own)
- **crictl**: v1.34.0
- **Network Plugin**: Calico

## Scripts

### common.sh
Common setup script for all nodes (control plane and worker nodes). This script:
- Disables swap
- Configures kernel modules (overlay, br_netfilter)
- Sets up networking parameters
- Installs containerd runtime
- Installs and configures crictl
- Installs kubelet, kubeadm, and kubectl

### master.sh
Control plane (master) node setup script. This script:
- Pulls required Kubernetes images
- Initializes the control plane using kubeadm
- Configures kubeconfig
- Installs Calico network plugin

### verify-setup.sh
Verification script to check installed components and their versions after setup.

## Usage

### 1. Setup Control Plane Node

```bash
# Run common setup
sudo bash common.sh

# Initialize control plane
sudo bash master.sh
```

### 2. Setup Worker Nodes

```bash
# Run common setup on each worker node
sudo bash common.sh

# Join the cluster using the command from master node output
sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

### 3. Verify Setup

```bash
# Check all component versions
bash verify-setup.sh
```

## Post-Installation

### Using crictl

crictl is configured to work with containerd. Common commands:

```bash
# List running containers
sudo crictl ps

# List all containers (including stopped)
sudo crictl ps -a

# List images
sudo crictl images

# List pods
sudo crictl pods

# Get runtime info
sudo crictl info

# Inspect a container
sudo crictl inspect <container-id>

# View container logs
sudo crictl logs <container-id>

# Execute command in container
sudo crictl exec -it <container-id> /bin/sh
```

### Using kubectl

```bash
# Check cluster status
kubectl cluster-info
kubectl get nodes
kubectl get pods -A

# Check component status
kubectl get componentstatuses
```

## Troubleshooting

### Check containerd status
```bash
sudo systemctl status containerd
sudo journalctl -u containerd -f
```

### Check kubelet status
```bash
sudo systemctl status kubelet
sudo journalctl -u kubelet -f
```

### Verify containerd configuration
```bash
sudo cat /etc/containerd/config.toml
```

### Verify crictl configuration
```bash
cat /etc/crictl.yaml
```

## Network Configuration

- **Pod Network CIDR**: 192.168.0.0/16 (Calico default)
- **Network Plugin**: Calico

## Important Notes

- Swap must be disabled for Kubernetes to work properly
- The scripts use `eth1` interface for node IP configuration (modify if your interface is different)
- SystemdCgroup is enabled in containerd for proper cgroup management
- All Kubernetes components are held from automatic updates using `apt-mark hold`

**Optionals : kubeadmin init via kubeadmin  config file
Create the Kubeadm Config**
vi kubeadm.config
In the following YAML, replace 192.168.201.10 with your control plane node's private IP in advertiseAddress.

For cloud VMs with a public IP we discussed earlier, update the controlPlaneEndpoint with the Public IP
If you don't need public access, use the private IP in controlPlaneEndpoint instead.
--------------------------------------------------------------------------------------------------------------------------------------
Step 6: Initialize Kubeadm On Controlplane Node
sudo kubeadm init --config=kubeadm.config

Step:7 
By default, apps won't get scheduled on the control plane node. If you want to use the control plane node for scheduling apps, taint the master node.

-- kubectl taint nodes --all node-role.kubernetes.io/control-plane-

You can add a label to the worker node using the following command. Replace node01 with the hostname of the worker node you want to labe
-- kubectl label node node01  node-role.kubernetes.io/worker=worker

Step 8: Install Calico Network Plugin for Pod Networking
-- Get the cluster CIDR range
kubectl -n kube-system get pod -l component=kube-controller-manager -o yaml | grep -i cluster-cidr
  
  1.1 Step 1: Install the Tigera Operator and Custom Resources
   Execute the following commands to install the Calico network plugin operator and CRD's on the cluster.
      kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.31.3/manifests/operator-crds.yaml
      kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.31.3/manifests/tigera-operator.yaml

  1.2 step:2 Download the Calico Custom Resource
  Use the following command to download the Calico custom resource.
   curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.31.3/manifests/custom-resources.yaml

  1.3 Step 3: Get the cluster CIDR range
  To get the cluster CIDR range, run the following command
      kubectl -n kube-system get pod -l component=kube-controller-manager -o yaml | grep -i cluster-cidr
      
  1.4 Step 4: Step 4: Customize custom-resources.yaml
  Open the custom-resources.yaml file and change the default CIDR from 192.168.0.0/16 to 10.244.0.0/16, which is the value specified in your kubeadm configuration
   <img width="871" height="511" alt="image" src="https://github.com/user-attachments/assets/fbd60af4-a990-44e6-9de4-cee44741858f" />

   1.5 Step 5: Deploy the custom resource
       kubectl apply -f custom-resources.yaml

   1.6 step  chekc pods calico
       watch kubectl get tigerastatus
