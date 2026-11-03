#!/usr/bin/env bash
# Check: beacon has 2 replicas, all available, the original image and exactly
# 2 pods that are not terminating (no drift left).
set -uo pipefail

dep="$(kubectl -n hangar get deployment beacon -o json 2>/dev/null || true)"
if [ -z "$dep" ]; then
  echo "FAIL: Deployment beacon not found in hangar"
  exit 1
fi
fail=0
desired="$(echo "$dep" | jq '.spec.replicas')"
available="$(echo "$dep" | jq '.status.availableReplicas // 0')"
image="$(echo "$dep" | jq -r '.spec.template.spec.containers[] | select(.name=="beacon") | .image')"
pods="$(kubectl -n hangar get pods -l app=beacon -o json 2>/dev/null | jq '[.items[] | select(.metadata.deletionTimestamp == null)] | length')"
[ "$desired" = "2" ] || { echo "FAIL: spec.replicas is $desired, expected 2 (the hand-made value 5 is drift)"; fail=1; }
[ "$available" = "2" ] || { echo "FAIL: availableReplicas is $available, expected 2"; fail=1; }
[ "$image" = "ghcr.io/stefanprodan/podinfo:6.15.0" ] || { echo "FAIL: image is '$image', expected ghcr.io/stefanprodan/podinfo:6.15.0"; fail=1; }
[ "${pods:-0}" = "2" ] || { echo "FAIL: found ${pods:-0} beacon pods, expected 2"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: beacon runs 2 available replicas"
exit "$fail"
