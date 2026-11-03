#!/usr/bin/env bash
# Starting state for the rollout lab. Environment only: it creates the
# workloads, waits for the healthy first revision and then releases a broken
# second revision of scout. It does not fix anything.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"

for name in scout probe shuttle; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
kubectl -n outpost rollout status deployment/drifter --timeout=180s

# Release the broken second revision. Do not wait for it: it never finishes.
kubectl -n starfleet patch deployment scout --patch-file "$DIR/manifests/scout-v2-broken.yaml"
echo "[lab] Ready."
