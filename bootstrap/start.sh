#!/bin/bash
#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd $SCRIPT_DIR
#install argocd
kubectl create namespace argocd
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argo-cd argo/argo-cd -n argocd -f $SCRIPT_DIR/argo-values.yml 

#argocd github ssh secret

kubectl apply  -f repo-secret.yaml -f app-base.yaml -f app-configuration.yaml