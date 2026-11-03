#!/usr/bin/env bash
# Check: SCOUT_TOKEN refers to the Secret scout-token key token, and no
# ConfigMap or plain env value holds the token.
set -uo pipefail

dep="$(kubectl -n dockyard get deployment scout -o json 2>/dev/null || true)"
[ -n "$dep" ] || { echo "FAIL: Deployment scout not found in dockyard"; exit 1; }
ref="$(echo "$dep" | jq -r '[.spec.template.spec.containers[0].env[]? | select(.name=="SCOUT_TOKEN") | .valueFrom.secretKeyRef | select(.name=="scout-token" and .key=="token")] | length')"
plain="$(echo "$dep" | jq -r '[.spec.template.spec.containers[0].env[]? | select(.name=="SCOUT_TOKEN") | .value // empty] | length')"
leak="$(kubectl -n dockyard get configmaps -o json 2>/dev/null | jq '[.items[].data // {} | to_entries[] | select(.value | contains("ensign-7f3a91"))] | length')"
fail=0
[ "$ref" = "1" ] || { echo "FAIL: SCOUT_TOKEN does not use secretKeyRef scout-token/token"; fail=1; }
[ "$plain" = "0" ] || { echo "FAIL: SCOUT_TOKEN has a plain value"; fail=1; }
[ "${leak:-0}" = "0" ] || { echo "FAIL: a ConfigMap holds the token value"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: the token is read from the Secret by reference"
exit "$fail"
