#!/usr/bin/env bash
# Check: The container reads MODE from the ConfigMap scout-settings, key mode, and no literal value is set.
set -uo pipefail

dep="$(kubectl -n hold get deployment scout -o json 2>/dev/null || true)"
[ -n "$dep" ] || { echo "FAIL: deployment scout not found in namespace hold"; exit 1; }
ref="$(echo "$dep" | jq -r '[.spec.template.spec.containers[0].env[]? | select(.name == "MODE") | .valueFrom.configMapKeyRef | select(. != null) | "\(.name)/\(.key)"] | first // ""')"
lit="$(echo "$dep" | jq -r '[.spec.template.spec.containers[0].env[]? | select(.name == "MODE" and .value != null)] | length')"
fail=0
[ "$ref" = "scout-settings/mode" ] || { echo "FAIL: MODE does not refer to scout-settings key mode (found '$ref')"; fail=1; }
[ "$lit" = "0" ] || { echo "FAIL: MODE also has a literal value"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: MODE is read from scout-settings key mode"
exit "$fail"
