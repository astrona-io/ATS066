#!/usr/bin/env bash
# Check: depot-settings holds tier=gold.
set -uo pipefail

tier="$(kubectl -n depot get configmap depot-settings -o jsonpath='{.data.tier}' 2>/dev/null || true)"
if [ "$tier" != "gold" ]; then
  echo "FAIL: data.tier is '$tier', expected 'gold'"
  exit 1
fi
echo "PASS: depot-settings holds tier=gold"
