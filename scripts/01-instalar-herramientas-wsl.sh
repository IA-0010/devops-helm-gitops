#!/usr/bin/env bash
set -euo pipefail
if [[ "$(uname -s)" != Linux || "$(uname -m)" != x86_64 ]]; then
  echo 'Este script requiere Ubuntu Linux x86_64 (WSL Ubuntu).'; exit 1
fi
sudo apt-get update -qq
sudo apt-get install -y -qq curl ca-certificates tar >/dev/null
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT
if ! command -v kind >/dev/null; then
  echo 'Instalando Kind v0.33.0...'
  curl -fL --retry 3 -o "$TMPDIR/kind" https://kind.sigs.k8s.io/dl/v0.33.0/kind-linux-amd64
  sudo install -m 0755 "$TMPDIR/kind" /usr/local/bin/kind
fi
if ! command -v kubectl >/dev/null; then
  echo 'Instalando kubectl...'
  KUBECTL_VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
  curl -fL --retry 3 -o "$TMPDIR/kubectl" "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
  sudo install -m 0755 "$TMPDIR/kubectl" /usr/local/bin/kubectl
fi
if ! command -v helm >/dev/null; then
  echo 'Instalando Helm 3.22.0...'
  curl -fL --retry 3 -o "$TMPDIR/helm.tgz" https://get.helm.sh/helm-v3.22.0-linux-amd64.tar.gz
  tar -xzf "$TMPDIR/helm.tgz" -C "$TMPDIR" linux-amd64/helm
  sudo install -m 0755 "$TMPDIR/linux-amd64/helm" /usr/local/bin/helm
fi
echo '--- Versiones instaladas ---'
kind version
kubectl version --client
helm version --short
