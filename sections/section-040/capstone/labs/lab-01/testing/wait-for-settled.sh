#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution: waits until preview
# has one and live has two relay pods, none terminating.
set -euo pipefail

want() {
  for i in $(seq 1 60); do
    total="$(kubectl -n "$1" get pods -l app=relay -o json | jq '.items | length')"
    terminating="$(kubectl -n "$1" get pods -l app=relay -o json | jq '[.items[] | select(.metadata.deletionTimestamp != null)] | length')"
    if [ "$total" = "$2" ] && [ "$terminating" = "0" ]; then
      return 0
    fi
    sleep 2
  done
  echo "[testing] $1 did not settle in time." >&2
  return 1
}
want preview 1
want live 2
echo "[testing] settled."
