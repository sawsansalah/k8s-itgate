# 🧪 Kind Cluster with NGINX Ingress – One-Step Script

This guide sets up a Kind cluster with NGINX Ingress and a test service accessible at `http://demo.local`, all in a single script.

---

## ✅ Step 1: Full Setup Script

Create and run the following script as `setup-kind-ingress.sh`:

```bash
#!/bin/bash

set -e

# Step 1: Write kind config
cat <<EOF > kind-config.yaml
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
EOF

# Step 2: Create Kind cluster
kind create cluster --name kind-ingress --config kind-config.yaml

# Step 3: Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/kind/deploy.yaml

# Wait for ingress controller to be ready
echo "⏳ Waiting for ingress controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=Ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# Step 4: Deploy a test app
kubectl create deployment demo --image=httpd --port=80
kubectl expose deployment demo --port=80 --target-port=80 --type=ClusterIP

# Step 5: Create ingress resource
cat <<EOF > ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: demo.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: demo
            port:
              number: 80
EOF

kubectl apply -f ingress.yaml

# Step 6: Update /etc/hosts
if ! grep -q "demo.local" /etc/hosts; then
  echo "🔧 Adding demo.local to /etc/hosts"
  echo "127.0.0.1 demo.local" | sudo tee -a /etc/hosts
else
  echo "✅ demo.local already exists in /etc/hosts"
fi

# Step 7: Test access
echo "🌐 Testing access to http://demo.local ..."
sleep 5
curl -I http://demo.local


