#!/bin/sh

KARGO_DIR=../../applications/kargo
helm dependency update ${KARGO_DIR}
pass=$(openssl rand -base64 48 | tr -d "=+/" | head -c 32)
echo "Password: $pass"
hashed_pass=$(htpasswd -bnBC 10 "" $pass | tr -d ':\n')
signing_key=$(openssl rand -base64 48 | tr -d "=+/" | head -c 32)
kubectl create namespace kargo
helm --debug template -n kargo kargo ${KARGO_DIR} --values ${KARGO_DIR}/values/prod.yaml \
  --set kargo.api.adminAccount.passwordHash=$hashed_pass \
  --set kargo.api.adminAccount.tokenSigningKey=$signing_key \
  | kubectl apply -f -
#kubectl apply -f manifests/
