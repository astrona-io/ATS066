#!/usr/bin/env bash
# Check: the ConfigMap hangar-settings has mode=active, owner=platform and the
# label managed-by=opentofu.
set -uo pipefail

cm="$(kubectl -n hangar get configmap hangar-settings -o json 2>/dev/null || true)"
if [ -z "$cm" ]; then
  echo "FAIL: ConfigMap hangar-settings not found in hangar"
  exit 1
fi
fail=0
mode="$(echo "$cm" | jq -r '.data.mode // ""')"
owner="$(echo "$cm" | jq -r '.data.owner // ""')"
label="$(echo "$cm" | jq -r '.metadata.labels["managed-by"] // ""')"
[ "$mode" = "active" ] || { echo "FAIL: data.mode is '$mode', expected 'active'"; fail=1; }
[ "$owner" = "platform" ] || { echo "FAIL: data.owner is '$owner', expected 'platform'"; fail=1; }
[ "$label" = "opentofu" ] || { echo "FAIL: label managed-by is '$label', expected 'opentofu'"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: hangar-settings has mode=active and owner=platform"
exit "$fail"
