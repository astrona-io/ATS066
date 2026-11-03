#!/usr/bin/env bash
# Check: the Deployment and every running pod read the generated ConfigMap
# through envFrom, and no hand-made PODINFO_UI_MESSAGE entry overrides it.
set -uo pipefail

name="$(kubectl -n starfleet get configmaps -o json 2>/dev/null | jq -r '[.items[] | select(.metadata.name | test("^scout-config-[a-z0-9]{10}$")) | .metadata.name][0] // ""')"
if [ -z "$name" ]; then
  echo "FAIL: no generated ConfigMap scout-config-<hash> exists"
  exit 1
fi

fail=0
container="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null | jq -c '.spec.template.spec.containers[] | select(.name=="scout")')"
ref="$(echo "$container" | jq -r '[.envFrom[]? | .configMapRef.name // empty][0] // ""')"
if [ "$ref" != "$name" ]; then
  echo "FAIL: the Deployment reads ConfigMap '$ref' through envFrom, expected '$name'"
  fail=1
fi

override="$(echo "$container" | jq '[.env[]? | select(.name=="PODINFO_UI_MESSAGE")] | length')"
if [ "$override" != "0" ]; then
  echo "FAIL: the template still sets PODINFO_UI_MESSAGE in env, which wins over envFrom"
  fail=1
fi

count=0
while IFS= read -r pod_ref; do
  count=$((count + 1))
  if [ "$pod_ref" != "$name" ]; then
    echo "FAIL: a running pod reads ConfigMap '$pod_ref', expected '$name'"
    fail=1
  fi
done < <(kubectl -n starfleet get pods -l app=scout -o json 2>/dev/null | jq -r '.items[] | select(.metadata.deletionTimestamp == null) | ([.spec.containers[] | select(.name=="scout") | .envFrom[]? | .configMapRef.name // empty][0] // "none")')
if [ "$count" != "2" ]; then
  echo "FAIL: found $count running scout pods, expected 2"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: the Deployment and both pods read $name and nothing overrides it"
fi
exit "$fail"
