#!/usr/bin/env bash
# Starting state: namespace dockyard with an unsafe scout Deployment (root,
# privileged) and the Secret scout-token. No Pod Security label, no identity.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n dockyard rollout status deployment/scout --timeout=240s
echo "[lab] Ready."
