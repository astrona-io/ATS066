#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

kubectl -n live rollout undo deployment/relay
kubectl -n live rollout status deployment/relay --timeout=240s
kubectl -n live annotate deployment relay kubernetes.io/change-cause="release r3 from rev-0107" --overwrite
for ns in preview live; do
  kubectl -n "$ns" patch deployment relay --type merge -p '{"spec":{"template":{"metadata":{"labels":{"release":"r3"}}}}}'
  kubectl -n "$ns" rollout status deployment/relay --timeout=240s
done
for i in $(seq 1 30); do
  id="$(kubectl -n live get pods -l app=relay,release=r3 -o jsonpath='{.items[0].status.containerStatuses[0].imageID}' 2>/dev/null || true)"
  [ -n "$id" ] && break
  sleep 2
done
kubectl -n live create configmap release-relay \
  --from-literal=version=r3 \
  --from-literal=digest="${id##*@}" \
  --from-literal=source-revision=rev-0107 \
  --from-literal=approved-by=platform-team
kubectl apply -f "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/solution.yaml"
echo "[solution] Applied."
