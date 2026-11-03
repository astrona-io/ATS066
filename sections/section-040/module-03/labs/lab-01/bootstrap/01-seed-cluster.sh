#!/usr/bin/env bash
# Starting state for the lab: Create namespace launch with scout-blue and a Service that selects version blue.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n launch rollout status deployment/scout-blue --timeout=240s
echo "[lab] Ready."
