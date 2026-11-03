#!/usr/bin/env bash
# Check: the digest in the release record equals the digest that every running
# scout pod reports in its imageID.
set -uo pipefail

recorded="$(kubectl -n starfleet get configmap release-scout -o jsonpath='{.data.digest}' 2>/dev/null || true)"
[ -n "$recorded" ] || { echo "FAIL: release-scout has no digest"; exit 1; }
ids="$(kubectl -n starfleet get pods -l app=scout -o json 2>/dev/null | jq -r '.items[] | select(.metadata.deletionTimestamp==null) | .status.containerStatuses[0].imageID // ""')"
[ -n "$ids" ] || { echo "FAIL: no scout pods found"; exit 1; }
fail=0
while IFS= read -r id; do
  live="${id##*@}"
  [ "$live" = "$recorded" ] || { echo "FAIL: a pod reports '$live', the record says '$recorded'"; fail=1; }
done <<< "$ids"
[ "$fail" -eq 0 ] && echo "PASS: every scout pod runs the recorded digest"
exit "$fail"
