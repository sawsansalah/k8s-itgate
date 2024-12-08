Installation Steps

wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

Modify the YAML File:

spec:
  containers:
    - args:
      - --cert-dir=/tmp
      - --secure-port=4443
      - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
      - --kubelet-use-node-status-port
      - --kubelet-insecure-tls  # Add this line
      - --metric-resolution=15s

Apply the Modified Manifest:

kubectl apply -f components.yaml