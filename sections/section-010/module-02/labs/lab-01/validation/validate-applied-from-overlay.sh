#!/usr/bin/env bash
# Check: the objects came from the overlay and were applied. The label
# environment=starfleet is on the Deployment, the Service and the ConfigMap,
# the Deployment has a last-applied annotation, and the label is not in the
# immutable selector (commonLabels would put it there).
set -uo pipefail

fail=0
for kind_and_name in deployment/scout service/scout; do
  value="$(kubectl -n starfleet get "$kind_and_name" -o json 2>/dev/null | jq -r '.metadata.labels.environment // ""')"
  if [ "$value" != "starfleet" ]; then
    echo "FAIL: $kind_and_name has no label environment=starfleet"
    fail=1
  fi
done

configmap_label="$(kubectl -n starfleet get configmaps -o json 2>/dev/null | jq -r '[.items[] | select(.metadata.name | test("^scout-config-[a-z0-9]{10}$")) | .metadata.labels.environment // ""][0] // ""')"
if [ "$configmap_label" != "starfleet" ]; then
  echo "FAIL: the generated ConfigMap has no label environment=starfleet"
  fail=1
fi

applied="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null | jq -r '.metadata.annotations["kubectl.kubernetes.io/last-applied-configuration"] // ""')"
if [ -z "$applied" ]; then
  echo "FAIL: deployment scout has no last-applied annotation, it was not applied with kubectl apply"
  fail=1
fi

selector="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null | jq -c '.spec.selector.matchLabels')"
if [ "$selector" != '{"app":"scout"}' ]; then
  echo "FAIL: the selector is $selector, expected {\"app\":\"scout\"}"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: the objects carry the overlay label and were applied with kubectl apply"
fi
exit "$fail"
