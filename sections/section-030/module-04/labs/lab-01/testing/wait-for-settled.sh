#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution: wait until two scout pods run the fixed image.
set -euo pipefail

for i in $(seq 1 60); do
  if [ "$(kubectl -n dock get deployment scout -o jsonpath='{.status.availableReplicas}' 2>/dev/null)" = "2" ] && [ "$(kubectl -n dock get pods -l app=scout -o json | jq '[.items[] | select(.metadata.deletionTimestamp != null)] | length')" = "0" ]; then
    echo "[testing] settled."
    exit 0
  fi
  sleep 2
done
echo "[testing] the lab did not settle in time." >&2
exit 1
