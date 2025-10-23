#!/bin/sh

CERTMANAGER_DIR=../../applications/cert-manager
helm dependency update ${CERTMANAGER_DIR}
kubectl create namespace cert-manager
helm --debug template -n cert-manager cert-manager ${CERTMANAGER_DIR} --values ${CERTMANAGER_DIR}/values/prod.yaml \
  | kubectl apply -f -
#kubectl apply -f manifests/
