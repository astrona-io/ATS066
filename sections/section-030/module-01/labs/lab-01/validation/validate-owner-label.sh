#!/usr/bin/env bash
# Check: the scout Deployment has the label owner=scout-team and still has two
# available replicas.
set -uo pipefail

dep="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null || true)"
[ -n "$dep" ] || { echo "FAIL: Deployment scout not found in starfleet"; exit 1; }
owner="$(echo "$dep" | jq -r '.metadata.labels.owner // ""')"
available="$(echo "$dep" | jq '.status.availableReplicas // 0')"
fail=0
[ "$owner" = "scout-team" ] || { echo "FAIL: label owner is '$owner', expected 'scout-team'"; fail=1; }
[ "$available" = "2" ] || { echo "FAIL: availableReplicas is $available, expected 2"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: scout is labelled owner=scout-team with 2 available replicas"
exit "$fail"
