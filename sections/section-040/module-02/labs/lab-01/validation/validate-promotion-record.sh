#!/usr/bin/env bash
# Check: ConfigMap promotion-record in production has release=r2, from=staging
# and the digest that the production pods report.
set -uo pipefail

cm="$(kubectl -n production get configmap promotion-record -o json 2>/dev/null || true)"
[ -n "$cm" ] || { echo "FAIL: ConfigMap promotion-record not found in production"; exit 1; }
fail=0
rel="$(echo "$cm" | jq -r '.data.release // ""')"
from="$(echo "$cm" | jq -r '.data.from // ""')"
dg="$(echo "$cm" | jq -r '.data["image-digest"] // ""')"
[ "$rel" = "r2" ] || { echo "FAIL: release is '$rel', expected 'r2'"; fail=1; }
[ "$from" = "staging" ] || { echo "FAIL: from is '$from', expected 'staging'"; fail=1; }
live="$(kubectl -n production get pods -l app=scout -o json 2>/dev/null | jq -r '[.items[] | select(.metadata.deletionTimestamp==null and .status.phase=="Running") | .status.containerStatuses[0].imageID // ""][0] // ""')"
live="${live##*@}"
[ -n "$dg" ] && [ "$dg" = "$live" ] || { echo "FAIL: image-digest is '$dg', production pods report '$live'"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: promotion-record matches production"
exit "$fail"
