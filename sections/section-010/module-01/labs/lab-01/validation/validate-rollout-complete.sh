#!/usr/bin/env bash
# Check: the rollout of scout finished. Every replica is updated, ready and
# available, the controller has seen the latest generation, and no pod of an
# older ReplicaSet is left running.
set -uo pipefail

deployment="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null || true)"
if [ -z "$deployment" ]; then
  echo "FAIL: deployment scout not found in starfleet"
  exit 1
fi

fail=0
generation="$(echo "$deployment" | jq '.metadata.generation')"
observed="$(echo "$deployment" | jq '.status.observedGeneration // 0')"
if [ "$generation" != "$observed" ]; then
  echo "FAIL: the controller has not seen the latest spec yet (generation $generation, observed $observed)"
  fail=1
fi

for field in updatedReplicas readyReplicas availableReplicas; do
  value="$(echo "$deployment" | jq ".status.$field // 0")"
  if [ "$value" != "3" ]; then
    echo "FAIL: status.$field is $value, expected 3"
    fail=1
  fi
done

replicas="$(echo "$deployment" | jq '.status.replicas // 0')"
if [ "$replicas" != "3" ]; then
  echo "FAIL: status.replicas is $replicas, expected 3 (an old or extra pod is still there)"
  fail=1
fi

progressing="$(echo "$deployment" | jq -r '[.status.conditions[]? | select(.type=="Progressing")][0].reason // ""')"
if [ "$progressing" = "ProgressDeadlineExceeded" ]; then
  echo "FAIL: the Progressing condition still reports ProgressDeadlineExceeded"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: scout finished its rollout with 3 updated, ready and available replicas"
fi
exit "$fail"
