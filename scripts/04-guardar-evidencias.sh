#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p evidencias
kubectl get nodes -o wide > evidencias/01-nodos-kubernetes.txt
kubectl get deployments,services,pods -n devops -o wide > evidencias/02-recursos-devops.txt
kubectl get applications.argoproj.io -n argocd -o wide > evidencias/03-estado-argocd.txt
kubectl get deployment devops-web -n devops -o jsonpath='{.spec.replicas} replicas deseadas / {.status.readyReplicas} listas{"\n"}' > evidencias/04-replicas.txt
printf 'Logs de evidencia guardados en evidencias/*.txt\n'
