#!/usr/bin/env bash
# Check: the API key stays in the existing Secret scout-key. The Deployment
# refers to it with secretKeyRef, no ConfigMap holds the value and Kustomize
# did not generate a second Secret.
set -uo pipefail

fail=0
value="$(kubectl -n outpost get secret scout-key -o json 2>/dev/null | jq -r '.data["api-key"] // "" | @base64d')"
if [ "$value" != "outpost-777" ]; then
  echo "FAIL: the Secret scout-key is missing or its api-key changed"
  fail=1
fi

reference="$(kubectl -n outpost get deployment scout -o json 2>/dev/null | jq -r '[.spec.template.spec.containers[] | select(.name=="scout") | .env[]? | select(.name=="SCOUT_API_KEY") | .valueFrom.secretKeyRef | "\(.name)/\(.key)"][0] // ""')"
if [ "$reference" != "scout-key/api-key" ]; then
  echo "FAIL: SCOUT_API_KEY refers to '$reference', expected a secretKeyRef to scout-key/api-key"
  fail=1
fi

leaks="$(kubectl -n outpost get configmaps -o json 2>/dev/null | jq '[.items[] | select((.data // {}) | to_entries | any(.value | tostring | contains("outpost-777")))] | length')"
if [ "$leaks" != "0" ]; then
  echo "FAIL: a ConfigMap in outpost contains the API key value"
  fail=1
fi
other="$(kubectl -n outpost get secrets -o json 2>/dev/null | jq '[.items[] | select(.metadata.name | startswith("scout-key-"))] | length')"
if [ "$other" != "0" ]; then
  echo "FAIL: a generated Secret scout-key-<hash> exists"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: SCOUT_API_KEY refers to the existing Secret and no ConfigMap holds the value"
fi
exit "$fail"
