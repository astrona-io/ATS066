#!/usr/bin/env bash
# Check: the rolling update strategy never lowers capacity: no unavailable pod
# and one surge pod. Accepts the integer 0 and the strings "0" and "0%".
set -uo pipefail

strategy="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null | jq -c '.spec.strategy')"
if [ -z "$strategy" ]; then
  echo "FAIL: deployment scout not found in starfleet"
  exit 1
fi

fail=0
type="$(echo "$strategy" | jq -r '.type // ""')"
if [ "$type" != "RollingUpdate" ]; then
  echo "FAIL: strategy type is '$type', expected RollingUpdate"
  fail=1
fi

unavailable="$(echo "$strategy" | jq -r '.rollingUpdate.maxUnavailable // "unset"')"
case "$unavailable" in
  0|"0%") ;;
  *)
    echo "FAIL: maxUnavailable is '$unavailable', expected 0"
    fail=1
    ;;
esac

surge="$(echo "$strategy" | jq -r '.rollingUpdate.maxSurge // "unset"')"
case "$surge" in
  1) ;;
  *)
    echo "FAIL: maxSurge is '$surge', expected 1"
    fail=1
    ;;
esac

if [ "$fail" -eq 0 ]; then
  echo "PASS: strategy is RollingUpdate with maxUnavailable 0 and maxSurge 1"
fi
exit "$fail"
