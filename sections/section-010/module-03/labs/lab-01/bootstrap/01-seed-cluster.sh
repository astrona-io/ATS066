#!/usr/bin/env bash
# Starting state for the lab: Create namespace hold with a ConfigMap and a Deployment made with kubectl create.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl create -f "$DIR/manifests/lab-start.yaml"
kubectl -n hold rollout status deployment/scout --timeout=240s
echo "[lab] Ready."
