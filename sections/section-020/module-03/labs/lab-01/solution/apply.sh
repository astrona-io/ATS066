#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl -n yard delete deployment relay --ignore-not-found
kubectl apply -f "$DIR/solution.yaml"
kubectl -n yard rollout status deployment/relay --timeout=240s
echo "[solution] Applied."
