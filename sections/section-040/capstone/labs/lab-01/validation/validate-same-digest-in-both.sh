#!/usr/bin/env bash
# Check: every running relay pod in preview and live reports the same digest.
set -uo pipefail

ids="$( (kubectl -n preview get pods -l app=relay -o json; kubectl -n live get pods -l app=relay -o json) 2>/dev/null | jq -r '.items[] | select(.metadata.deletionTimestamp==null and .status.phase=="Running") | .status.containerStatuses[0].imageID // ""')"
[ -n "$ids" ] || { echo "FAIL: no running relay pods found"; exit 1; }
count="$(echo "$ids" | sed 's/.*@//' | sort -u | wc -l | tr -d ' ')"
[ "$count" = "1" ] || { echo "FAIL: pods report $count different image identifiers"; exit 1; }
echo "PASS: all relay pods run the same image identifier"
