#!/usr/bin/env bash
# Check: relay-pipeline in live can update only the Deployment relay, cannot
# read Secrets or touch preview, and has no token mounted by default.
set -uo pipefail

who="system:serviceaccount:live:relay-pipeline"
sa="$(kubectl -n live get serviceaccount relay-pipeline -o json 2>/dev/null || true)"
[ -n "$sa" ] || { echo "FAIL: ServiceAccount relay-pipeline not found in live"; exit 1; }
fail=0
check() {
  expected="$1"; shift; desc="$1"; shift
  got="$(kubectl auth can-i "$@" --as="$who" 2>/dev/null || true)"
  [ "$got" = "$expected" ] || { echo "FAIL: $desc: answer was '$got', expected '$expected'"; fail=1; }
}
check yes "patch deployment relay in live" patch deployment/relay -n live
check yes "list deployments in live" list deployments -n live
check no "patch deployment other in live" patch deployment/other -n live
check no "delete deployments in live" delete deployments -n live
check no "read secrets in live" get secrets -n live
check no "patch deployment relay in preview" patch deployment/relay -n preview
mount="$(echo "$sa" | jq -r '.automountServiceAccountToken // "unset"')"
[ "$mount" = "false" ] || { echo "FAIL: automountServiceAccountToken is '$mount', expected 'false'"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: relay-pipeline has only the rights it needs"
exit "$fail"
