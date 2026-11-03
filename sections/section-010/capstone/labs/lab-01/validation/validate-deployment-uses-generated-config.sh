#!/usr/bin/env bash
# Check: the Deployment template and every running pod take PODINFO_UI_MESSAGE
# from the generated ConfigMap, and the Deployment was applied with the
# overlay label and a last-applied annotation. The selector stays app=scout.
set -uo pipefail

name="$(kubectl -n outpost get configmaps -o json 2>/dev/null | jq -r '[.items[] | select(.metadata.name | test("^scout-settings-[a-z0-9]{10}$")) | .metadata.name][0] // ""')"
if [ -z "$name" ]; then
  echo "FAIL: no generated ConfigMap scout-settings-<hash> exists"
  exit 1
fi

fail=0
deployment="$(kubectl -n outpost get deployment scout -o json 2>/dev/null || true)"
ref="$(echo "$deployment" | jq -r '[.spec.template.spec.containers[] | select(.name=="scout") | .env[]? | select(.name=="PODINFO_UI_MESSAGE") | .valueFrom.configMapKeyRef.name][0] // ""')"
if [ "$ref" != "$name" ]; then
  echo "FAIL: the template reads ConfigMap '$ref', expected '$name'"
  fail=1
fi

count=0
while IFS= read -r pod_ref; do
  count=$((count + 1))
  if [ "$pod_ref" != "$name" ]; then
    echo "FAIL: a running pod reads ConfigMap '$pod_ref', expected '$name'"
    fail=1
  fi
done < <(kubectl -n outpost get pods -l app=scout -o json 2>/dev/null | jq -r '.items[] | select(.metadata.deletionTimestamp == null) | ([.spec.containers[] | select(.name=="scout") | .env[]? | select(.name=="PODINFO_UI_MESSAGE") | .valueFrom.configMapKeyRef.name][0] // "none")')
if [ "$count" != "3" ]; then
  echo "FAIL: found $count running scout pods, expected 3"
  fail=1
fi

label="$(echo "$deployment" | jq -r '.metadata.labels.environment // ""')"
if [ "$label" != "outpost" ]; then
  echo "FAIL: deployment scout has no label environment=outpost"
  fail=1
fi
applied="$(echo "$deployment" | jq -r '.metadata.annotations["kubectl.kubernetes.io/last-applied-configuration"] // ""')"
if [ -z "$applied" ]; then
  echo "FAIL: deployment scout has no last-applied annotation"
  fail=1
fi
selector="$(echo "$deployment" | jq -c '.spec.selector.matchLabels')"
if [ "$selector" != '{"app":"scout"}' ]; then
  echo "FAIL: the selector is $selector, expected {\"app\":\"scout\"}"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: the template and all 3 pods read $name"
fi
exit "$fail"
