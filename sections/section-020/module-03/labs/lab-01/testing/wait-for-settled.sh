#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution: wait until two relay pods are ready with the new label.
set -euo pipefail

for i in $(seq 1 60); do
  if [ "$(kubectl -n yard get pods -l app.kubernetes.io/name=relay --field-selector=status.phase=Running -o json | jq '[.items[] | select(.metadata.deletionTimestamp == null)] | length')" = "2" ]; then
    echo "[testing] settled."
    exit 0
  fi
  sleep 2
done
echo "[testing] the lab did not settle in time." >&2
exit 1
