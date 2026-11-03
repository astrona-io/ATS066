#!/usr/bin/env bash
# Check: every running scout pod in staging and production reports the same
# image digest.
set -uo pipefail

ids="$( (kubectl -n staging get pods -l app=scout -o json; kubectl -n production get pods -l app=scout -o json) 2>/dev/null | jq -r '.items[] | select(.metadata.deletionTimestamp==null and .status.phase=="Running") | .status.containerStatuses[0].imageID // ""')"
[ -n "$ids" ] || { echo "FAIL: no running scout pods found"; exit 1; }
count="$(echo "$ids" | sed 's/.*@//' | sort -u | wc -l | tr -d ' ')"
if [ "$count" != "1" ]; then
  echo "FAIL: pods report $count different image identifiers"
  exit 1
fi
echo "PASS: all scout pods run the same image identifier"
