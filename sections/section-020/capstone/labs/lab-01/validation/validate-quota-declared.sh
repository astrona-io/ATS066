#!/usr/bin/env bash
# Check: ResourceQuota depot-quota allows 10 pods and carries managed-by=opentofu.
set -uo pipefail

quota="$(kubectl -n depot get resourcequota depot-quota -o json 2>/dev/null || true)"
if [ -z "$quota" ]; then
  echo "FAIL: ResourceQuota depot-quota not found in depot"
  exit 1
fi
fail=0
pods="$(echo "$quota" | jq -r '.spec.hard.pods // ""')"
label="$(echo "$quota" | jq -r '.metadata.labels["managed-by"] // ""')"
[ "$pods" = "10" ] || { echo "FAIL: spec.hard.pods is '$pods', expected '10'"; fail=1; }
[ "$label" = "opentofu" ] || { echo "FAIL: label managed-by is '$label', expected 'opentofu'"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: depot-quota allows 10 pods"
exit "$fail"
