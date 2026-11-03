#!/usr/bin/env bash
# Check: The namespace dock has the label supply-chain=checked.
set -uo pipefail

v="$(kubectl get namespace dock -o json 2>/dev/null | jq -r '.metadata.labels["supply-chain"] // ""')"
if [ "$v" = "checked" ]; then echo "PASS: dock is labelled supply-chain=checked"; exit 0; fi
echo "FAIL: label supply-chain on dock is '$v', expected 'checked'"
exit 1
