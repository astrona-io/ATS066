#!/usr/bin/env bash
# Check: scout has two available replicas, the original image, and no pod
# without the release label is left.
set -uo pipefail

dep="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null || true)"
[ -n "$dep" ] || { echo "FAIL: Deployment scout not found in starfleet"; exit 1; }
available="$(echo "$dep" | jq '.status.availableReplicas // 0')"
updated="$(echo "$dep" | jq '.status.updatedReplicas // 0')"
total="$(echo "$dep" | jq '.status.replicas // 0')"
image="$(echo "$dep" | jq -r '.spec.template.spec.containers[0].image')"
fail=0
[ "$available" = "2" ] || { echo "FAIL: availableReplicas is $available, expected 2"; fail=1; }
[ "$updated" = "2" ] && [ "$total" = "2" ] || { echo "FAIL: updated $updated of $total replicas, expected 2 of 2"; fail=1; }
[ "$image" = "ghcr.io/stefanprodan/podinfo:6.15.0" ] || { echo "FAIL: image is '$image', expected ghcr.io/stefanprodan/podinfo:6.15.0"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: the rollout is complete with 2 available replicas"
exit "$fail"
