#!/usr/bin/env bash
# Check: bay-team can deploy in bay and has no other rights, and its Role has
# no wildcard.
set -uo pipefail

who="system:serviceaccount:bay:bay-team"
kubectl -n bay get serviceaccount bay-team >/dev/null 2>&1 || { echo "FAIL: ServiceAccount bay-team not found in bay"; exit 1; }
fail=0
check() {
  expected="$1"; shift; desc="$1"; shift
  got="$(kubectl auth can-i "$@" --as="$who" 2>/dev/null || true)"
  [ "$got" = "$expected" ] || { echo "FAIL: $desc: answer was '$got', expected '$expected'"; fail=1; }
}
check yes "patch deployments in bay" patch deployments -n bay
check yes "list pods in bay" list pods -n bay
check no "delete deployments in bay" delete deployments -n bay
check no "read secrets in bay" get secrets -n bay
check no "create rolebindings in bay" create rolebindings -n bay
check no "list pods in default" list pods -n default
role="$(kubectl -n bay get rolebindings -o json 2>/dev/null | jq -r '[.items[] | select(any(.subjects[]?; .kind=="ServiceAccount" and .name=="bay-team")) | .roleRef | select(.kind=="Role") | .name] | first // ""')"
if [ -z "$role" ]; then
  echo "FAIL: no RoleBinding gives a Role to bay-team"; fail=1
else
  wild="$(kubectl -n bay get role "$role" -o json 2>/dev/null | jq '[.rules[] | (.verbs[], .resources[], .apiGroups[]) | select(. == "*")] | length')"
  [ "${wild:-1}" = "0" ] || { echo "FAIL: Role $role uses a wildcard"; fail=1; }
fi
[ "$fail" -eq 0 ] && echo "PASS: bay-team has only the rights it needs"
exit "$fail"
