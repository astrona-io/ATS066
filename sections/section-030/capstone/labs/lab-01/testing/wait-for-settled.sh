#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution: waits until exactly
# two relay pods are left and none is terminating.
set -euo pipefail

for i in $(seq 1 60); do
  total="$(kubectl -n bay get pods -l app=relay -o json | jq '.items | length')"
  terminating="$(kubectl -n bay get pods -l app=relay -o json | jq '[.items[] | select(.metadata.deletionTimestamp != null)] | length')"
  if [ "$total" = "2" ] && [ "$terminating" = "0" ]; then
    echo "[testing] settled."
    exit 0
  fi
  sleep 2
done
echo "[testing] relay did not settle in time." >&2
exit 1
