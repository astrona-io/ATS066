#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`: rolls production
# back, labels both templates with the release and writes the promotion record.
set -euo pipefail

kubectl -n production rollout undo deployment/scout
kubectl -n production rollout status deployment/scout --timeout=240s
for ns in staging production; do
  kubectl -n "$ns" patch deployment scout --type merge -p '{"spec":{"template":{"metadata":{"labels":{"release":"r2"}}}}}'
  kubectl -n "$ns" rollout status deployment/scout --timeout=240s
done
for i in $(seq 1 30); do
  id="$(kubectl -n production get pods -l app=scout,release=r2 -o jsonpath='{.items[0].status.containerStatuses[0].imageID}' 2>/dev/null || true)"
  [ -n "$id" ] && break
  sleep 2
done
kubectl -n production create configmap promotion-record \
  --from-literal=release=r2 \
  --from-literal=from=staging \
  --from-literal=image-digest="${id##*@}"
echo "[solution] Applied."
