#!/usr/bin/env bash
# Starting state for the lab: Create namespace yard with the Deployment relay and its Service.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n yard rollout status deployment/relay --timeout=240s
echo "[lab] Ready."
