#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if ! docker info >/dev/null 2>&1; then
  echo 'ERROR: Docker Desktop no responde desde Ubuntu WSL. Abre Docker Desktop y habilita WSL Integration > Ubuntu.' >&2; exit 1
fi
if kind get clusters | grep -qx 'devops-gitops'; then
  echo 'El cluster devops-gitops ya existe.'
  kind export kubeconfig --name devops-gitops
else
  kind create cluster --name devops-gitops --config kind/cluster.yaml --wait 240s
fi
kubectl config use-context kind-devops-gitops
kubectl get nodes -o wide
