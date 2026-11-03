#!/usr/bin/env bash
# Check: Both Deployments carry the part-of label and the right owner label.
set -uo pipefail

fail=0
for pair in "scout:scout-team" "probe:probe-team"; do
  name="${pair%%:*}"; team="${pair##*:}"
  dep="$(kubectl -n ops get deployment "$name" -o json 2>/dev/null || true)"
  [ -n "$dep" ] || { echo "FAIL: deployment $name not found in namespace ops"; fail=1; continue; }
  part="$(echo "$dep" | jq -r '.metadata.labels["app.kubernetes.io/part-of"] // ""')"
  owner="$(echo "$dep" | jq -r '.metadata.labels.owner // ""')"
  [ "$part" = "starfleet" ] || { echo "FAIL: $name label app.kubernetes.io/part-of is '$part', expected 'starfleet'"; fail=1; }
  [ "$owner" = "$team" ] || { echo "FAIL: $name label owner is '$owner', expected '$team'"; fail=1; }
done
[ "$fail" -eq 0 ] && echo "PASS: both Deployments carry part-of and owner labels"
exit "$fail"
