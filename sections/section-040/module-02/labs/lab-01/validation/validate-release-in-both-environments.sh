#!/usr/bin/env bash
# Check: the template label release=r2 is set in staging and production, and
# the running pods carry it (one in staging, two in production).
set -uo pipefail

fail=0
for pair in staging:1 production:2; do
  ns="${pair%%:*}"; want="${pair##*:}"
  tpl="$(kubectl -n "$ns" get deployment scout -o jsonpath='{.spec.template.metadata.labels.release}' 2>/dev/null || true)"
  [ "$tpl" = "r2" ] || { echo "FAIL: $ns template label release is '$tpl', expected 'r2'"; fail=1; continue; }
  n="$(kubectl -n "$ns" get pods -l app=scout,release=r2 -o json | jq '[.items[] | select(.status.phase=="Running" and .metadata.deletionTimestamp==null)] | length')"
  [ "${n:-0}" = "$want" ] || { echo "FAIL: $ns has $n running pods with release=r2, expected $want"; fail=1; }
done
[ "$fail" -eq 0 ] && echo "PASS: release r2 runs in staging and production"
exit "$fail"
