#!/usr/bin/env bash
# Check: the rollout finished. Three updated, ready and available replicas,
# the controller saw the latest generation, no progress failure, original image,
# and the template already uses a generated ConfigMap.
set -uo pipefail

deployment="$(kubectl -n outpost get deployment scout -o json 2>/dev/null || true)"
if [ -z "$deployment" ]; then
  echo "FAIL: deployment scout not found in outpost"
  exit 1
fi

fail=0
generation="$(echo "$deployment" | jq '.metadata.generation')"
observed="$(echo "$deployment" | jq '.status.observedGeneration // 0')"
if [ "$generation" != "$observed" ]; then
  echo "FAIL: the controller has not seen the latest spec yet"
  fail=1
fi
for field in replicas updatedReplicas readyReplicas availableReplicas; do
  value="$(echo "$deployment" | jq ".status.$field // 0")"
  if [ "$value" != "3" ]; then
    echo "FAIL: status.$field is $value, expected 3"
    fail=1
  fi
done
reason="$(echo "$deployment" | jq -r '[.status.conditions[]? | select(.type=="Progressing")][0].reason // ""')"
if [ "$reason" = "ProgressDeadlineExceeded" ]; then
  echo "FAIL: the Progressing condition reports ProgressDeadlineExceeded"
  fail=1
fi
image="$(echo "$deployment" | jq -r '.spec.template.spec.containers[] | select(.name=="scout") | .image')"
if [ "$image" != "ghcr.io/stefanprodan/podinfo:6.15.0" ]; then
  echo "FAIL: scout runs image '$image', expected ghcr.io/stefanprodan/podinfo:6.15.0"
  fail=1
fi

ref="$(echo "$deployment" | jq -r '[.spec.template.spec.containers[] | select(.name=="scout") | .env[]? | select(.name=="PODINFO_UI_MESSAGE") | .valueFrom.configMapKeyRef.name][0] // ""')"
if ! echo "$ref" | grep -Eq '^scout-settings-[a-z0-9]{10}$'; then
  echo "FAIL: the new configuration has not been rolled out yet (template reads '$ref')"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: scout finished its rollout with 3 available replicas"
fi
exit "$fail"
