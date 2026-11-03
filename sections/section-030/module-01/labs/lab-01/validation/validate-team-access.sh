#!/usr/bin/env bash
# Check: scout-team can deploy in starfleet and nothing more.
set -uo pipefail

who="system:serviceaccount:starfleet:scout-team"
fail=0
check() { # expected, description, args...
  expected="$1"; shift; desc="$1"; shift
  got="$(kubectl auth can-i "$@" --as="$who" 2>/dev/null || true)"
  if [ "$got" != "$expected" ]; then
    echo "FAIL: $desc: answer was '$got', expected '$expected'"
    fail=1
  fi
}
kubectl -n starfleet get serviceaccount scout-team >/dev/null 2>&1 || { echo "FAIL: ServiceAccount scout-team not found in starfleet"; exit 1; }
check yes "patch deployments in starfleet" patch deployments -n starfleet
check yes "create deployments in starfleet" create deployments -n starfleet
check yes "read pod logs in starfleet" get pods --subresource=log -n starfleet
check yes "list services in starfleet" list services -n starfleet
check no "delete deployments in starfleet" delete deployments -n starfleet
check no "read secrets in starfleet" get secrets -n starfleet
check no "create rolebindings in starfleet" create rolebindings -n starfleet
check no "patch deployments in outpost" patch deployments -n outpost
[ "$fail" -eq 0 ] && echo "PASS: scout-team can deploy and read in starfleet and has no other access"
exit "$fail"
