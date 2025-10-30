#!/bin/sh

APP_DIR=../../applications/onepassword-connect
helm dependency update ${APP_DIR}
op_json="$(op document get --vault homelab "Scorpius Credentials File" --format json | base64 | tr '/+' '_-' | tr -d '=' | tr -d '\n')"
op_token="$(op item get --vault homelab "Scorpius Access Token: Scorpius" --fields credential --reveal)"
kubectl create namespace onepassword-connect
kubectl -n onepassword-connect create secret generic op-credentials --from-literal=1password-credentials.json="$op_json"
kubectl -n onepassword-connect create secret generic onepassword-token --from-literal=token="$op_token"
helm template -n onepassword-connect onepassword-connect ${APP_DIR} --values ${APP_DIR}/values.yaml --include-crds \
  | kubectl apply -f -
#kubectl apply -f manifests/
