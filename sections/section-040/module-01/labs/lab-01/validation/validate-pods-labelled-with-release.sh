#!/usr/bin/env bash
# Check: the pod template and both running pods carry the label release=rev-0042.
set -uo pipefail

dep="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null || true)"
[ -n "$dep" ] || { echo "FAIL: Deployment scout not found in starfleet"; exit 1; }
tpl="$(echo "$dep" | jq -r '.spec.template.metadata.labels.release // ""')"
[ "$tpl" = "rev-0042" ] || { echo "FAIL: pod template label release is '$tpl', expected 'rev-0042'"; exit 1; }
n="$(kubectl -n starfleet get pods -l app=scout,release=rev-0042 -o json | jq '[.items[] | select(.status.phase=="Running" and .metadata.deletionTimestamp==null)] | length')"
[ "${n:-0}" = "2" ] || { echo "FAIL: $n running pods with the release label, expected 2"; exit 1; }
echo "PASS: two running scout pods carry release=rev-0042"
