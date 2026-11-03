#!/usr/bin/env bash
# Check: Scout has two available replicas and probe has one.
set -uo pipefail

fail=0
s="$(kubectl -n ops get deployment scout -o jsonpath='{.status.availableReplicas}' 2>/dev/null)"
p="$(kubectl -n ops get deployment probe -o jsonpath='{.status.availableReplicas}' 2>/dev/null)"
[ "${s:-0}" = "2" ] || { echo "FAIL: scout has ${s:-0} available replicas, expected 2"; fail=1; }
[ "${p:-0}" = "1" ] || { echo "FAIL: probe has ${p:-0} available replicas, expected 1"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: scout and probe are available"
exit "$fail"
