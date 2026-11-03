#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl apply -f "$DIR/solution.yaml"
kubectl -n launch rollout status deployment/scout-green --timeout=240s
kubectl -n launch rollout status deployment/scout-blue --timeout=240s
echo "[solution] Applied."
