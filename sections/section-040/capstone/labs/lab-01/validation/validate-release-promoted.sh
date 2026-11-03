#!/usr/bin/env bash
# Check: release=r3 is on the template and the pods in preview (one) and live
# (two), and replicas and settings are untouched.
set -uo pipefail

fail=0
for pair in preview:1 live:2; do
  ns="${pair%%:*}"; want="${pair##*:}"
  tpl="$(kubectl -n "$ns" get deployment relay -o jsonpath='{.spec.template.metadata.labels.release}' 2>/dev/null || true)"
  [ "$tpl" = "r3" ] || { echo "FAIL: $ns template label release is '$tpl', expected 'r3'"; fail=1; continue; }
  n="$(kubectl -n "$ns" get pods -l app=relay,release=r3 -o json | jq '[.items[] | select(.status.phase=="Running" and .metadata.deletionTimestamp==null)] | length')"
  [ "${n:-0}" = "$want" ] || { echo "FAIL: $ns has $n running pods with release=r3, expected $want"; fail=1; }
  rep="$(kubectl -n "$ns" get deployment relay -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
  [ "$rep" = "$want" ] || { echo "FAIL: $ns has $rep replicas, expected $want"; fail=1; }
  env="$(kubectl -n "$ns" get configmap relay-settings -o jsonpath='{.data.environment}' 2>/dev/null || true)"
  [ "$env" = "$ns" ] || { echo "FAIL: $ns ConfigMap environment is '$env', expected '$ns'"; fail=1; }
done
[ "$fail" -eq 0 ] && echo "PASS: release r3 runs in preview and live with their own settings"
exit "$fail"
