#!/usr/bin/env bash
# Check: the RoleBinding gives a Role of starfleet to scout-team, and no rule
# of that Role uses a wildcard.
set -uo pipefail

bindings="$(kubectl -n starfleet get rolebindings -o json 2>/dev/null || true)"
role="$(echo "$bindings" | jq -r '[.items[] | select(any(.subjects[]?; .kind=="ServiceAccount" and .name=="scout-team")) | .roleRef | select(.kind=="Role") | .name] | first // ""')"
if [ -z "$role" ]; then
  echo "FAIL: no RoleBinding gives a Role to the ServiceAccount scout-team"
  exit 1
fi
wild="$(kubectl -n starfleet get role "$role" -o json 2>/dev/null | jq '[.rules[] | (.verbs[], .resources[], .apiGroups[]) | select(. == "*")] | length')"
if [ "${wild:-1}" != "0" ]; then
  echo "FAIL: Role $role uses a wildcard in verbs, resources or apiGroups"
  exit 1
fi
echo "PASS: scout-team is bound to Role $role and the Role has no wildcard"
