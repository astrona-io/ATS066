#!/usr/bin/env bash
# Check: Scout has at least two revisions and the newest revision records a change cause.
set -uo pipefail

rs="$(kubectl -n ops get replicasets -l app=scout -o json 2>/dev/null || true)"
[ -n "$rs" ] || { echo "FAIL: no ReplicaSets found for scout in namespace ops"; exit 1; }
fail=0
count="$(echo "$rs" | jq '[.items[] | select(.metadata.annotations["deployment.kubernetes.io/revision"] != null)] | length')"
[ "$count" -ge 2 ] || { echo "FAIL: scout has $count revisions, expected at least 2"; fail=1; }
cause="$(echo "$rs" | jq -r '[.items[] | select(.metadata.annotations["deployment.kubernetes.io/revision"] != null)] | sort_by(.metadata.annotations["deployment.kubernetes.io/revision"] | tonumber) | last | .metadata.annotations["kubernetes.io/change-cause"] // ""')"
[ -n "${cause// /}" ] || { echo "FAIL: the newest revision has no kubernetes.io/change-cause"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: $count revisions, newest cause '$cause'"
exit "$fail"
