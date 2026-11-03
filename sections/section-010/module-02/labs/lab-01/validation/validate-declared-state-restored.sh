#!/usr/bin/env bash
# Check: the cluster matches the declared state. scout has 2 replicas, all
# available, with the original image, and no extra or terminating pods.
set -uo pipefail

deployment="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null || true)"
if [ -z "$deployment" ]; then
  echo "FAIL: deployment scout not found in starfleet"
  exit 1
fi

fail=0
desired="$(echo "$deployment" | jq '.spec.replicas')"
if [ "$desired" != "2" ]; then
  echo "FAIL: spec.replicas is $desired, expected 2 (the hand-made value 5 is drift)"
  fail=1
fi
for field in updatedReplicas readyReplicas availableReplicas replicas; do
  value="$(echo "$deployment" | jq ".status.$field // 0")"
  if [ "$value" != "2" ]; then
    echo "FAIL: status.$field is $value, expected 2"
    fail=1
  fi
done
image="$(echo "$deployment" | jq -r '.spec.template.spec.containers[] | select(.name=="scout") | .image')"
if [ "$image" != "ghcr.io/stefanprodan/podinfo:6.15.0" ]; then
  echo "FAIL: scout runs image '$image', expected ghcr.io/stefanprodan/podinfo:6.15.0"
  fail=1
fi
pods="$(kubectl -n starfleet get pods -l app=scout -o json 2>/dev/null | jq '[.items[] | select(.metadata.deletionTimestamp == null)] | length')"
if [ "${pods:-0}" != "2" ]; then
  echo "FAIL: found ${pods:-0} running scout pods, expected 2"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: scout runs 2 available replicas with its original image"
fi
exit "$fail"
