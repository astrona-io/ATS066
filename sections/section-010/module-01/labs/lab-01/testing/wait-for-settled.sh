#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution: waits until no old or
# terminating scout pod is left.
set -euo pipefail

for i in $(seq 1 45); do
  total="$(kubectl -n starfleet get pods -l app=scout -o json | jq '.items | length')"
  terminating="$(kubectl -n starfleet get pods -l app=scout -o json | jq '[.items[] | select(.metadata.deletionTimestamp != null)] | length')"
  if [ "$total" = "3" ] && [ "$terminating" = "0" ]; then
    echo "[testing] settled."
    exit 0
  fi
  sleep 2
done
echo "[testing] scout did not settle in time." >&2
exit 1
