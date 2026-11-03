#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Record the cause first, so it is copied to the revision that the fix creates.
kubectl -n starfleet annotate deployment/scout --overwrite \
  kubernetes.io/change-cause="release scout v2 with a working readiness probe"

kubectl -n starfleet patch deployment scout --patch-file "$DIR/solution.yaml"
kubectl -n starfleet rollout status deployment/scout --timeout=240s
echo "[solution] Applied."
