#!/usr/bin/env bash
# Starting state for the capstone. Environment only: it creates namespace
# outpost with the scout service, a plain ConfigMap, a Secret and a client. It
# does not create the learner's files, the generated ConfigMap or the evidence.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"

kubectl -n outpost rollout status deployment/scout --timeout=240s
kubectl -n outpost rollout status deployment/drifter --timeout=180s
echo "[lab] Ready."
