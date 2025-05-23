openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=login.example.com/O=example.com"

kubectl create secret tls my-tls-secret \
  --cert=tls.crt \
  --key=tls.key \
  -n default

