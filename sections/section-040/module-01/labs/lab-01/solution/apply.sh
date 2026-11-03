#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`: labels the pod
# template, records the change cause and writes the release record from the
# digest that the pods report.
set -euo pipefail

kubectl -n starfleet annotate deployment scout kubernetes.io/change-cause="release 6.15.0 from rev-0042" --overwrite
kubectl -n starfleet patch deployment scout --type merge -p '{"spec":{"template":{"metadata":{"labels":{"release":"rev-0042"}}}}}'
kubectl -n starfleet rollout status deployment/scout --timeout=240s

for i in $(seq 1 30); do
  id="$(kubectl -n starfleet get pods -l app=scout,release=rev-0042 -o jsonpath='{.items[0].status.containerStatuses[0].imageID}' 2>/dev/null || true)"
  [ -n "$id" ] && break
  sleep 2
done
digest="${id##*@}"
kubectl -n starfleet create configmap release-scout \
  --from-literal=version=6.15.0 \
  --from-literal=digest="$digest" \
  --from-literal=source-revision=rev-0042 \
  --from-literal=approved-by=platform-team
echo "[solution] Applied."
