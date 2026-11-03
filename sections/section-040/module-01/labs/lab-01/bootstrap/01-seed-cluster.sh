#!/usr/bin/env bash
# Starting state: the Starfleet workloads only. No release record exists and
# the scout Deployment carries no release label or change cause.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
for name in scout probe shuttle; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=240s
done
kubectl -n outpost rollout status deployment/drifter --timeout=180s
echo "[lab] Ready."
