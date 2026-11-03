#!/usr/bin/env bash
# Check: the intended release went forward and was not rolled back. The
# template and every running pod carry PODINFO_UI_MESSAGE=scout v2.
set -uo pipefail

expected="scout v2"
fail=0

template="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null | jq -r '.spec.template.spec.containers[] | select(.name=="scout") | .env[]? | select(.name=="PODINFO_UI_MESSAGE") | .value')"
if [ "$template" != "$expected" ]; then
  echo "FAIL: the pod template has PODINFO_UI_MESSAGE '$template', expected '$expected' (a rollback removes the release)"
  fail=1
fi

pods="$(kubectl -n starfleet get pods -l app=scout -o json 2>/dev/null)"
count=0
while IFS= read -r message; do
  count=$((count + 1))
  if [ "$message" != "$expected" ]; then
    echo "FAIL: a running scout pod has PODINFO_UI_MESSAGE '$message', expected '$expected'"
    fail=1
  fi
done < <(echo "$pods" | jq -r '.items[] | select(.metadata.deletionTimestamp == null) | (.spec.containers[] | select(.name=="scout") | .env[]? | select(.name=="PODINFO_UI_MESSAGE") | .value) // ""')

if [ "$count" -ne 3 ]; then
  echo "FAIL: found $count running scout pods, expected 3"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: all 3 scout pods run the release with the message '$expected'"
fi
exit "$fail"
