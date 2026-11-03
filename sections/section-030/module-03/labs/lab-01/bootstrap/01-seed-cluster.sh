#!/usr/bin/env bash
# Starting state for the lab: Create namespace ops with the Deployments scout and probe and no ownership data.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n ops rollout status deployment/scout --timeout=240s
kubectl -n ops rollout status deployment/probe --timeout=240s
echo "[lab] Ready."
