#!/usr/bin/env bash
# Check: The Service scout selects app=scout and version=green.
set -uo pipefail

sel="$(kubectl -n launch get service scout -o json 2>/dev/null | jq -c '.spec.selector // {}')"
app="$(echo "$sel" | jq -r '.app // ""')"
ver="$(echo "$sel" | jq -r '.version // ""')"
if [ "$app" = "scout" ] && [ "$ver" = "green" ]; then echo "PASS: the selector is $sel"; exit 0; fi
echo "FAIL: the selector is $sel, expected app=scout and version=green"
exit 1
