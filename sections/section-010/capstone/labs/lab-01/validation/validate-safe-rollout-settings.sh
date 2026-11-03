#!/usr/bin/env bash
# Check: the Deployment is set up for a safe rollout. RollingUpdate with
# maxUnavailable 0 and maxSurge 1, minReadySeconds at least 10, a progress
# deadline from 30 to 120 seconds, and an HTTP readiness probe on /readyz.
set -uo pipefail

deployment="$(kubectl -n outpost get deployment scout -o json 2>/dev/null || true)"
if [ -z "$deployment" ]; then
  echo "FAIL: deployment scout not found in outpost"
  exit 1
fi

fail=0
unavailable="$(echo "$deployment" | jq -r '.spec.strategy.rollingUpdate.maxUnavailable // "unset"')"
case "$unavailable" in
  0|"0%") ;;
  *)
    echo "FAIL: maxUnavailable is '$unavailable', expected 0"
    fail=1
    ;;
esac
surge="$(echo "$deployment" | jq -r '.spec.strategy.rollingUpdate.maxSurge // "unset"')"
if [ "$surge" != "1" ]; then
  echo "FAIL: maxSurge is '$surge', expected 1"
  fail=1
fi

min_ready="$(echo "$deployment" | jq '.spec.minReadySeconds // 0')"
deadline="$(echo "$deployment" | jq '.spec.progressDeadlineSeconds // 600')"
if [ "$min_ready" -lt 10 ]; then
  echo "FAIL: minReadySeconds is $min_ready, expected at least 10"
  fail=1
fi
if [ "$deadline" -gt 120 ] || [ "$deadline" -lt 30 ] || [ "$deadline" -le "$min_ready" ]; then
  echo "FAIL: progressDeadlineSeconds is $deadline, expected 30 to 120 and above minReadySeconds"
  fail=1
fi

path="$(echo "$deployment" | jq -r '[.spec.template.spec.containers[] | select(.name=="scout") | .readinessProbe.httpGet.path][0] // ""')"
if [ "$path" != "/readyz" ]; then
  echo "FAIL: the readiness probe path is '$path', expected /readyz"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: strategy 1/0, minReadySeconds $min_ready, deadline $deadline, readiness on /readyz"
fi
exit "$fail"
