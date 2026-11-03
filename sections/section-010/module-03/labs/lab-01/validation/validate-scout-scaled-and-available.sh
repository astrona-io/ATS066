#!/usr/bin/env bash
# Check: Deployment scout has two replicas and both are available.
set -uo pipefail

dep="$(kubectl -n hold get deployment scout -o json 2>/dev/null || true)"
[ -n "$dep" ] || { echo "FAIL: deployment scout not found in namespace hold"; exit 1; }
fail=0
spec="$(echo "$dep" | jq '.spec.replicas')"
avail="$(echo "$dep" | jq '.status.availableReplicas // 0')"
[ "$spec" = "2" ] || { echo "FAIL: spec.replicas is $spec, expected 2"; fail=1; }
[ "$avail" = "2" ] || { echo "FAIL: $avail replicas available, expected 2"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: scout runs two available replicas"
exit "$fail"
