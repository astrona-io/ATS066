#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution: wait until green has two available pods and blue has one.
set -euo pipefail

for i in $(seq 1 60); do
  if [ "$(kubectl -n launch get deployment scout-green -o jsonpath='{.status.availableReplicas}' 2>/dev/null)" = "2" ] && [ "$(kubectl -n launch get deployment scout-blue -o jsonpath='{.status.availableReplicas}' 2>/dev/null)" = "1" ] && [ "$(kubectl -n launch get pods -l app=scout -o json | jq '[.items[] | select(.metadata.deletionTimestamp != null)] | length')" = "0" ]; then
    echo "[testing] settled."
    exit 0
  fi
  sleep 2
done
echo "[testing] the lab did not settle in time." >&2
exit 1
