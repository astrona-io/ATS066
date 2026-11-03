#!/usr/bin/env bash
# Check: the namespace dockyard enforces and warns at the restricted level.
set -uo pipefail

ns="$(kubectl get namespace dockyard -o json 2>/dev/null || true)"
[ -n "$ns" ] || { echo "FAIL: namespace dockyard not found"; exit 1; }
fail=0
for mode in enforce warn; do
  v="$(echo "$ns" | jq -r --arg k "pod-security.kubernetes.io/$mode" '.metadata.labels[$k] // ""')"
  [ "$v" = "restricted" ] || { echo "FAIL: label pod-security.kubernetes.io/$mode is '$v', expected 'restricted'"; fail=1; }
done
[ "$fail" -eq 0 ] && echo "PASS: dockyard enforces and warns at the restricted level"
exit "$fail"
