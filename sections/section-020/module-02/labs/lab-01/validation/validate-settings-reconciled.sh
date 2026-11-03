#!/usr/bin/env bash
# Check: hangar-settings holds mode=active and owner=platform.
set -uo pipefail

mode="$(kubectl -n hangar get configmap hangar-settings -o jsonpath='{.data.mode}' 2>/dev/null || true)"
owner="$(kubectl -n hangar get configmap hangar-settings -o jsonpath='{.data.owner}' 2>/dev/null || true)"
fail=0
[ "$mode" = "active" ] || { echo "FAIL: data.mode is '$mode', expected 'active'"; fail=1; }
[ "$owner" = "platform" ] || { echo "FAIL: data.owner is '$owner', expected 'platform'"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: hangar-settings holds mode=active and owner=platform"
exit "$fail"
