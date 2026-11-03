#!/usr/bin/env bash
# Check: Two relay pods run with the new label and no pod with the old label is left.
set -uo pipefail

fail=0
dep="$(kubectl -n yard get deployment relay -o json 2>/dev/null || true)"
[ -n "$dep" ] || { echo "FAIL: deployment relay not found in namespace yard"; exit 1; }
avail="$(echo "$dep" | jq '.status.availableReplicas // 0')"
[ "$avail" = "2" ] || { echo "FAIL: $avail replicas available, expected 2"; fail=1; }
old="$(kubectl -n yard get pods -l app=relay -o json | jq '[.items[] | select(.metadata.deletionTimestamp == null)] | length')"
[ "$old" = "0" ] || { echo "FAIL: $old pods still carry the old label app=relay"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: two relay pods are available and none has the old label"
exit "$fail"
