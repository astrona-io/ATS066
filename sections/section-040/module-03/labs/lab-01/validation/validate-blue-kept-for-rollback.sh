#!/usr/bin/env bash
# Check: The Deployment scout-blue still exists with exactly one available replica.
set -uo pipefail

dep="$(kubectl -n launch get deployment scout-blue -o json 2>/dev/null || true)"
[ -n "$dep" ] || { echo "FAIL: deployment scout-blue was deleted; keep it for rollback"; exit 1; }
fail=0
spec="$(echo "$dep" | jq '.spec.replicas // 0')"
avail="$(echo "$dep" | jq '.status.availableReplicas // 0')"
[ "$spec" = "1" ] || { echo "FAIL: scout-blue has $spec replicas, expected 1"; fail=1; }
[ "$avail" = "1" ] || { echo "FAIL: $avail blue replicas available, expected 1"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: scout-blue is kept with one replica"
exit "$fail"
