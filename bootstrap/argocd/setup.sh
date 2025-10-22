#!/bin/sh

ARGOCD_DIR=../../applications/argocd
helm dependency update ${ARGOCD_DIR}
helm template -n argocd argocd ${ARGOCD_DIR} --values ${ARGOCD_DIR}/values/prod.yaml | kubectl apply -f -
kubectl apply -f manifests/
