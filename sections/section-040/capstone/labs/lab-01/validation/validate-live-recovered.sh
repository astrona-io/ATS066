#!/usr/bin/env bash
# Check: live relay uses the good image, has two available replicas and no pod
# that tries to run the broken image.
set -uo pipefail

dep="$(kubectl -n live get deployment relay -o json 2>/dev/null || true)"
[ -n "$dep" ] || { echo "FAIL: Deployment relay not found in live"; exit 1; }
image="$(echo "$dep" | jq -r '.spec.template.spec.containers[0].image')"
available="$(echo "$dep" | jq '.status.availableReplicas // 0')"
bad="$(kubectl -n live get pods -l app=relay -o json | jq '[.items[] | select(.spec.containers[0].image | contains("does-not-exist"))] | length')"
fail=0
[ "$image" = "ghcr.io/stefanprodan/podinfo:6.15.0" ] || { echo "FAIL: template image is '$image', expected ghcr.io/stefanprodan/podinfo:6.15.0"; fail=1; }
[ "$available" = "2" ] || { echo "FAIL: availableReplicas is $available, expected 2"; fail=1; }
[ "$bad" = "0" ] || { echo "FAIL: $bad pods still use the broken image"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: live runs the good image with 2 available replicas"
exit "$fail"
