#!/usr/bin/env bash
# Check: scout-deploy can update only the Deployment scout in dockyard, cannot
# read Secrets, and has no token mounted by default.
set -uo pipefail

who="system:serviceaccount:dockyard:scout-deploy"
sa="$(kubectl -n dockyard get serviceaccount scout-deploy -o json 2>/dev/null || true)"
[ -n "$sa" ] || { echo "FAIL: ServiceAccount scout-deploy not found in dockyard"; exit 1; }
fail=0
check() {
  expected="$1"; shift; desc="$1"; shift
  got="$(kubectl auth can-i "$@" --as="$who" 2>/dev/null || true)"
  [ "$got" = "$expected" ] || { echo "FAIL: $desc: answer was '$got', expected '$expected'"; fail=1; }
}
check yes "patch deployment scout" patch deployment/scout -n dockyard
check no "patch deployment other" patch deployment/other -n dockyard
check no "delete deployments" delete deployments -n dockyard
check no "read secrets" get secrets -n dockyard
check no "create rolebindings" create rolebindings -n dockyard
check no "list pods in kube-system" list pods -n kube-system
mount="$(echo "$sa" | jq -r '.automountServiceAccountToken // "unset"')"
[ "$mount" = "false" ] || { echo "FAIL: automountServiceAccountToken is '$mount', expected 'false'"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: scout-deploy has only the rights it needs"
exit "$fail"
