#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution: wait until all pods of both Deployments are ready.
set -euo pipefail

for i in $(seq 1 60); do
  if [ "$(kubectl -n ops get deployment scout -o jsonpath='{.status.availableReplicas}' 2>/dev/null)" = "2" ] && [ "$(kubectl -n ops get deployment probe -o jsonpath='{.status.availableReplicas}' 2>/dev/null)" = "1" ] && [ "$(kubectl -n ops get pods -l app=scout -o json | jq '[.items[] | select(.metadata.deletionTimestamp != null)] | length')" = "0" ]; then
    echo "[testing] settled."
    exit 0
  fi
  sleep 2
done
echo "[testing] the lab did not settle in time." >&2
exit 1
