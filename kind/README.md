# Kind Cluster Configuration

This directory contains the Kubernetes-in-Docker (Kind) cluster configuration and Helm chart definitions for the demo environment.

## Structure

```
kind/
├── .kind/
│   └── config.yaml           # Kind cluster definition with port mappings
├── signoz-ingress.yaml       # Ingress resource for Signoz UI
├── helmfile.d/               # Helm chart configurations
│   ├── 03-ingress-nginx.yaml # Nginx Ingress Controller chart
│   ├── 04-signoz.yaml        # Signoz platform chart
│   └── values/               # Custom Helm values
│       ├── signoz/           # Signoz resource limits and settings
│       └── ingress-nginx/    # Ingress controller settings
└── .kube/                    # Generated KUBECONFIG (auto-created)
```

## Configuration Files

### `.kind/config.yaml`
Defines the Kind cluster with:
- Single control-plane node
- Extra port mappings (80, 443) for Ingress access
- Kubernetes version 1.33.4

### `signoz-ingress.yaml`
Manual Ingress resource for Signoz UI at `signoz.localhost`.  
**Note**: This is a workaround for Signoz Helm chart ingress configuration issues.

### `helmfile.d/`
Contains Helm chart definitions deployed by `setup.sh`:
- **Nginx Ingress**: NodePort service with hostPort enabled
- **Signoz**: Observability platform with custom resource limits

## Usage

This directory is used automatically by `setup.sh`. Manual usage:

```bash
# Create cluster
kind create cluster --config kind/.kind/config.yaml --name signoz-demo

# Set KUBECONFIG
export KUBECONFIG=$PWD/kind/.kube/config

# Apply Signoz ingress
kubectl apply -f kind/signoz-ingress.yaml
```

## Notes

- The `.kube/` directory is auto-generated and should not be committed
- Port mappings (80, 443) enable local access without port-forwarding
- Signoz chart version is pinned to 0.104.1 for stability
