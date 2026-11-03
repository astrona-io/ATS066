#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Preview the drift, as the learner does. kubectl diff exits 1 when it finds a
# difference, which is expected here.
kubectl diff -k "$DIR/files/overlays/starfleet" || true

kubectl apply -k "$DIR/files/overlays/starfleet"

# The hand-made message in env was never in a manifest, so apply keeps it and
# it wins over envFrom. Remove it with a strategic merge delete directive.
kubectl -n starfleet patch deployment scout --type=strategic \
  -p '{"spec":{"template":{"spec":{"containers":[{"name":"scout","env":[{"name":"PODINFO_UI_MESSAGE","$patch":"delete"}]}]}}}}'

kubectl -n starfleet rollout status deployment/scout --timeout=240s
echo "[solution] Applied."
