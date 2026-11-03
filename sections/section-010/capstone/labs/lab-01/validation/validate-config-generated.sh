#!/usr/bin/env bash
# Check: Kustomize generated exactly one ConfigMap scout-settings-<hash> with
# the message "scout v2" and the overlay label, and the old ConfigMap with the
# fixed name scout-settings is gone.
set -uo pipefail

fail=0
configmaps="$(kubectl -n outpost get configmaps -o json 2>/dev/null)"

if echo "$configmaps" | jq -e '.items[] | select(.metadata.name == "scout-settings")' >/dev/null 2>&1; then
  echo "FAIL: the old ConfigMap scout-settings (fixed name) still exists"
  fail=1
fi

generated="$(echo "$configmaps" | jq -c '[.items[] | select(.metadata.name | test("^scout-settings-[a-z0-9]{10}$"))]')"
count="$(echo "$generated" | jq 'length')"
if [ "$count" != "1" ]; then
  echo "FAIL: found $count ConfigMaps named scout-settings-<hash>, expected 1"
  exit 1
fi

message="$(echo "$generated" | jq -r '.[0].data.message // ""')"
if [ "$message" != "scout v2" ]; then
  echo "FAIL: the generated ConfigMap has message '$message', expected 'scout v2'"
  fail=1
fi
label="$(echo "$generated" | jq -r '.[0].metadata.labels.environment // ""')"
if [ "$label" != "outpost" ]; then
  echo "FAIL: the generated ConfigMap has no label environment=outpost"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: one generated ConfigMap with the message 'scout v2'; the fixed-name ConfigMap is gone"
fi
exit "$fail"
