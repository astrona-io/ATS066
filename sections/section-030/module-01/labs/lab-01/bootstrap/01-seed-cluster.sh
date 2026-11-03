#!/usr/bin/env bash
# Starting state: the Starfleet workloads only. No identity, role, quota or
# default limits exist yet. The learner builds the platform contract.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
for name in scout probe shuttle; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=240s
done
kubectl -n outpost rollout status deployment/drifter --timeout=180s
echo "[lab] Ready."
