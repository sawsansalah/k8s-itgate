wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

Add insecure TLS parameter to the components.yaml file
metadata:
      labels:
        k8s-app: metrics-server
    spec:
      containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --kubelet-insecure-tls   <==== Add this

   kubectl apply -f components.yaml
     
