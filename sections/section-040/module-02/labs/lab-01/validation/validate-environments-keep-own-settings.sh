#!/usr/bin/env bash
# Check: each environment keeps its replica count, its own ConfigMap value and
# the envFrom reference.
set -uo pipefail

fail=0
for pair in staging:1 production:2; do
  ns="${pair%%:*}"; want="${pair##*:}"
  rep="$(kubectl -n "$ns" get deployment scout -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
  env="$(kubectl -n "$ns" get configmap scout-settings -o jsonpath='{.data.environment}' 2>/dev/null || true)"
  ref="$(kubectl -n "$ns" get deployment scout -o json 2>/dev/null | jq -r '[.spec.template.spec.containers[0].envFrom[]? | .configMapRef.name] | join(",")')"
  [ "$rep" = "$want" ] || { echo "FAIL: $ns has $rep replicas, expected $want"; fail=1; }
  [ "$env" = "$ns" ] || { echo "FAIL: $ns ConfigMap environment is '$env', expected '$ns'"; fail=1; }
  [ "$ref" = "scout-settings" ] || { echo "FAIL: $ns envFrom is '$ref', expected scout-settings"; fail=1; }
done
[ "$fail" -eq 0 ] && echo "PASS: both environments keep their own replicas and settings"
exit "$fail"
