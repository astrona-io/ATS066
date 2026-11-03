#!/usr/bin/env bash
# Starting state for the configuration lab. Environment only: it creates the
# workloads, a Secret and a scout Deployment made by hand (five replicas and a
# message in env). It does not create the learner's files or objects.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl apply -f "$DIR/manifests/scout-token.yaml"
# `create`, not `apply`: the hand-made objects get no last-applied annotation.
kubectl create -f "$DIR/manifests/scout-by-hand.yaml"

for name in probe shuttle; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
kubectl -n starfleet rollout status deployment/scout --timeout=240s
kubectl -n outpost rollout status deployment/drifter --timeout=180s
echo "[lab] Ready."
