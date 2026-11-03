#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution: waits until exactly
# two beacon pods are running and none is terminating.
set -euo pipefail

for i in $(seq 1 45); do
  total="$(kubectl -n hangar get pods -l app=beacon -o json | jq '.items | length')"
  terminating="$(kubectl -n hangar get pods -l app=beacon -o json | jq '[.items[] | select(.metadata.deletionTimestamp != null)] | length')"
  if [ "$total" = "2" ] && [ "$terminating" = "0" ]; then
    echo "[testing] settled."
    exit 0
  fi
  sleep 2
done
echo "[testing] beacon did not settle in time." >&2
exit 1
