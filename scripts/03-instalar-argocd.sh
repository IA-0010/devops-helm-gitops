#!/usr/bin/env bash
set -euo pipefail
kubectl config use-context kind-devops-gitops
helm repo add argo https://argoproj.github.io/argo-helm --force-update
helm repo update argo
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  --set dex.enabled=false --set notifications.enabled=false --set applicationSet.enabled=false \
  --wait --timeout 12m
kubectl -n argocd get pods
printf '\nPara abrir Argo CD en OTRA terminal:\n'
printf 'kubectl -n argocd port-forward svc/argocd-server 8085:443\n'
printf 'URL: https://localhost:8085 / Usuario: admin\n'
printf 'Para obtener la clave desde Ubuntu:\n'
printf "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo\n"
