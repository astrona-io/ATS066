#!/usr/bin/env bash
# Starting state for the lab: Create namespace dock with a scout Deployment that uses the tag latest.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n dock rollout status deployment/scout --timeout=240s
echo "[lab] Ready."
