# 1. Create Kind cluster with Ingress support

Create `kind-config.yaml`:

```yaml

kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP

```yaml

kind create cluster --name ingress-cluster --config kind-config.yaml

# 2. Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# 3. Verify installation
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

kubectl get pods -n ingress-nginx

# 4. Create test application
kubectl create deployment demo --image=httpd --port=80
kubectl expose deployment demo

# 5. Create Ingress resource
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo-ingress
spec:
  rules:
  - host: demo.localdev.me
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: demo
            port:
              number: 80
```yaml

# 6. Update hosts file (Linux/Mac)
echo "127.0.0.1 demo.localdev.me" | sudo tee -a /etc/hosts

# 7. Test access
curl -v http://demo.localdev.me
