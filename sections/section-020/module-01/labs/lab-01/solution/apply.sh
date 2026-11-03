#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`. It creates the
# objects that the OpenTofu files in solution/files declare, with kubectl.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl apply -f "$DIR/solution.yaml"
kubectl -n hangar rollout status deployment/beacon --timeout=240s
echo "[solution] Applied."
