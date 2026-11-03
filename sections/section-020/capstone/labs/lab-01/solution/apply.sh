#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`. It reaches the
# end state of the OpenTofu files with kubectl, keeping the imported objects.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl label namespace depot managed-by=opentofu --overwrite
kubectl -n depot label configmap depot-settings managed-by=opentofu --overwrite
kubectl -n depot patch configmap depot-settings --type=merge -p '{"data":{"tier":"gold"}}'
kubectl apply -f "$DIR/solution.yaml"
kubectl -n depot rollout status deployment/relay --timeout=240s
echo "[solution] Applied."
