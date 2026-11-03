#!/usr/bin/env bash
# Check: scout has two replicas, all available, with the original image.
set -uo pipefail

dep="$(kubectl -n dockyard get deployment scout -o json 2>/dev/null || true)"
[ -n "$dep" ] || { echo "FAIL: Deployment scout not found in dockyard"; exit 1; }
desired="$(echo "$dep" | jq '.spec.replicas')"
available="$(echo "$dep" | jq '.status.availableReplicas // 0')"
image="$(echo "$dep" | jq -r '.spec.template.spec.containers[0].image')"
fail=0
[ "$desired" = "2" ] || { echo "FAIL: spec.replicas is $desired, expected 2"; fail=1; }
[ "$available" = "2" ] || { echo "FAIL: availableReplicas is $available, expected 2"; fail=1; }
[ "$image" = "ghcr.io/stefanprodan/podinfo:6.15.0" ] || { echo "FAIL: image is '$image', expected ghcr.io/stefanprodan/podinfo:6.15.0"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: scout has 2 available replicas with the original image"
exit "$fail"
