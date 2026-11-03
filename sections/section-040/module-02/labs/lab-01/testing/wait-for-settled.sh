#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution: waits until staging
# has one and production has two scout pods, none terminating.
set -euo pipefail

want() { # namespace, count
  for i in $(seq 1 60); do
    total="$(kubectl -n "$1" get pods -l app=scout -o json | jq '.items | length')"
    terminating="$(kubectl -n "$1" get pods -l app=scout -o json | jq '[.items[] | select(.metadata.deletionTimestamp != null)] | length')"
    if [ "$total" = "$2" ] && [ "$terminating" = "0" ]; then
      return 0
    fi
    sleep 2
  done
  echo "[testing] $1 did not settle in time." >&2
  return 1
}
want staging 1
want production 2
echo "[testing] settled."
