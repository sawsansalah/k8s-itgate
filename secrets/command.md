# Kubernetes Secrets Usage Guide

## 🔐 Creating Secrets from Files

```bash
echo -n 'admin' > username.txt
echo -n 'password' > password.txt

kubectl create secret generic database-credentials \
    --from-file=username.txt \
    --from-file=password.txt \
    --namespace=secrets-demo
```

Verify the secret:

```bash
kubectl -n secrets-demo get secrets
```

---

## 📄 Creating Secrets Using a Manifest File

Encode credentials in base64:

```bash
echo -n 'admin' | base64
# Output: YWRtaW4=

echo -n 'password' | base64
# Output: cGFzc3dvcmQ=
```

Create a file `demo-secret.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: demo-secret
type: Opaque
data:
  username: YWRtaW4=
  password: cGFzc3dvcmQ=
```

Apply the secret:

```bash
kubectl -n secrets-demo apply -f demo-secret.yaml
```

---

## 🌐 Using Secret Data as Environment Variables

Create a pod manifest `secret-test-env-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: env-pod
spec:
  containers:
    - name: secret-test
      image: nginx
      env:
        - name: USER
          valueFrom:
            secretKeyRef:
              name: database-credentials
              key: username.txt
        - name: PASSWORD
          valueFrom:
            secretKeyRef:
              name: database-credentials
              key: password.txt
```

Deploy and check logs:

```bash
kubectl -n secrets-demo apply -f secret-test-env-pod.yaml
kubectl -n secrets-demo describe pod env-pod
kubectl -n secrets-demo logs env-pod
```

---

## 📁 Using Secret Data as Files in a Volume

Create a pod manifest `secret-test-volume-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata: 
  name: volume-test-pod
spec:
  containers:
    - name: secret-test
      image: nginx
      volumeMounts:
        - name: secret-volume
          mountPath: /etc/config/secret
  volumes:
    - name: secret-volume
      secret:
        secretName: database-credentials
```

Deploy and test:

```bash
kubectl -n secrets-demo apply -f secret-test-volume-pod.yaml

kubectl -n secrets-demo exec volume-test-pod -- cat /etc/config/secret/username.txt
kubectl -n secrets-demo exec volume-test-pod -- cat /etc/config/secret/password.txt
kubectl -n secrets-demo exec volume-test-pod -- ls /etc/config/secret
```
    
