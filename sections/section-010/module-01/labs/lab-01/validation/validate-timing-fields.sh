#!/usr/bin/env bash
# Check: minReadySeconds is at least 10 and the progress deadline is between
# 30 and 120 seconds and larger than minReadySeconds.
set -uo pipefail

deployment="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null || true)"
if [ -z "$deployment" ]; then
  echo "FAIL: deployment scout not found in starfleet"
  exit 1
fi

fail=0
min_ready="$(echo "$deployment" | jq '.spec.minReadySeconds // 0')"
deadline="$(echo "$deployment" | jq '.spec.progressDeadlineSeconds // 600')"

if [ "$min_ready" -lt 10 ]; then
  echo "FAIL: minReadySeconds is $min_ready, expected at least 10"
  fail=1
fi
if [ "$deadline" -gt 120 ] || [ "$deadline" -lt 30 ]; then
  echo "FAIL: progressDeadlineSeconds is $deadline, expected a value from 30 to 120"
  fail=1
fi
if [ "$deadline" -le "$min_ready" ]; then
  echo "FAIL: progressDeadlineSeconds ($deadline) must be larger than minReadySeconds ($min_ready)"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: minReadySeconds is $min_ready and progressDeadlineSeconds is $deadline"
fi
exit "$fail"
