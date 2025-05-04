# Kind Cluster with NGINX Ingress Setup

This guide walks through setting up a local [Kind (Kubernetes IN Docker)](https://kind.sigs.k8s.io/) cluster with support for NGINX ingress, allowing you to expose services on `localhost` via custom hostnames.

---

## 🧰 Prerequisites

- Docker
- Kind installed (`go install sigs.k8s.io/kind@latest`)
- kubectl installed

---

## 📦 Step 1: Create Kind Config

Save the following as `kind-config.yaml`:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        protocol: TCP
