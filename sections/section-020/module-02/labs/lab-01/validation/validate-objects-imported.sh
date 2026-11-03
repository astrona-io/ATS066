#!/usr/bin/env bash
# Check: the namespace, the ConfigMap and the Deployment are the objects that
# existed at the start (same unique identifiers), so they were imported and
# not deleted and created again.
set -uo pipefail

record="$(kubectl -n default get configmap seed-record -o json 2>/dev/null || true)"
if [ -z "$record" ]; then
  echo "FAIL: the ConfigMap seed-record is missing from the namespace default. Do not delete it."
  exit 1
fi
fail=0
check_uid() {
  local label="$1" key="$2" actual="$3"
  local expected
  expected="$(echo "$record" | jq -r ".data[\"$key\"]")"
  if [ -z "$actual" ]; then
    echo "FAIL: $label not found"
    fail=1
  elif [ "$actual" != "$expected" ]; then
    echo "FAIL: $label has a new unique identifier, so it was deleted and created again. Import it instead."
    fail=1
  fi
}
check_uid "namespace hangar" namespace-uid "$(kubectl get namespace hangar -o jsonpath='{.metadata.uid}' 2>/dev/null || true)"
check_uid "ConfigMap hangar-settings" configmap-uid "$(kubectl -n hangar get configmap hangar-settings -o jsonpath='{.metadata.uid}' 2>/dev/null || true)"
check_uid "Deployment beacon" deployment-uid "$(kubectl -n hangar get deployment beacon -o jsonpath='{.metadata.uid}' 2>/dev/null || true)"
[ "$fail" -eq 0 ] && echo "PASS: all three objects keep their original unique identifiers"
exit "$fail"
