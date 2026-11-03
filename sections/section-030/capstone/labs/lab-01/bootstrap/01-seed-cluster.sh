#!/usr/bin/env bash
# Starting state: namespace bay with an unsafe relay Deployment, a Secret and
# no quota, no default limits, no identity and no Pod Security label.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n bay rollout status deployment/relay --timeout=240s
echo "[lab] Ready."
