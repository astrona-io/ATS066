#!/usr/bin/env bash
# Check: a LimitRange in starfleet gives containers a default CPU request of
# 50m, a default memory request of 64Mi and a default memory limit of 128Mi.
set -uo pipefail

ranges="$(kubectl -n starfleet get limitrange -o json 2>/dev/null || true)"
ok="$(echo "$ranges" | jq '[.items[].spec.limits[] | select(.type=="Container" and .defaultRequest.cpu=="50m" and .defaultRequest.memory=="64Mi" and .default.memory=="128Mi")] | length')"
if [ "${ok:-0}" -lt 1 ]; then
  echo "FAIL: no LimitRange in starfleet has defaultRequest cpu=50m, memory=64Mi and default memory=128Mi for containers"
  exit 1
fi
echo "PASS: the LimitRange defaults exist"
