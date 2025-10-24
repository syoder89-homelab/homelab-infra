helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane crossplane-stable/crossplane --namespace crossplane-system --create-namespace
sleep 5
crossplane xpkg install provider xpkg.crossplane.io/crossplane-contrib/provider-helm:v1.0.2
sleep 5
kubectl apply -f ./manifests/
