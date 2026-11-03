#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl apply --server-side --field-manager=release-pipeline --force-conflicts -f "$DIR/solution.yaml"
kubectl -n hold rollout status deployment/scout --timeout=240s
echo "[solution] Applied."
