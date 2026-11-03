#!/usr/bin/env bash
# Check: every running beacon pod has the environment variable mode=active.
# A pod that started before the ConfigMap changed still shows the old value.
set -uo pipefail

pods="$(kubectl -n hangar get pods -l app=beacon -o json 2>/dev/null | jq -r '.items[] | select(.metadata.deletionTimestamp == null) | .metadata.name')"
if [ -z "$pods" ]; then
  echo "FAIL: no beacon pods found in hangar"
  exit 1
fi
fail=0
count=0
for pod in $pods; do
  count=$((count + 1))
  value="$(kubectl -n hangar exec "$pod" -- printenv mode 2>/dev/null || true)"
  if [ "$value" != "active" ]; then
    echo "FAIL: pod $pod has mode='$value', expected 'active' (restart the pods after the ConfigMap change)"
    fail=1
  fi
done
[ "$count" -eq 2 ] || { echo "FAIL: found $count beacon pods, expected 2"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: both beacon pods read mode=active"
exit "$fail"
