#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl apply -f "$DIR/solution.yaml"
kubectl -n ops rollout status deployment/scout --timeout=240s
kubectl -n ops rollout status deployment/probe --timeout=240s
echo "[solution] Applied."
