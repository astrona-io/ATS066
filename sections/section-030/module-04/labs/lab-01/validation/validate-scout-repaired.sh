#!/usr/bin/env bash
# Check: Scout runs two available replicas with the image ghcr.io/stefanprodan/podinfo:6.15.0.
set -uo pipefail

dep="$(kubectl -n dock get deployment scout -o json 2>/dev/null || true)"
[ -n "$dep" ] || { echo "FAIL: deployment scout not found in namespace dock"; exit 1; }
fail=0
img="$(echo "$dep" | jq -r '.spec.template.spec.containers[0].image')"
avail="$(echo "$dep" | jq '.status.availableReplicas // 0')"
[ "$img" = "ghcr.io/stefanprodan/podinfo:6.15.0" ] || { echo "FAIL: image is '$img', expected ghcr.io/stefanprodan/podinfo:6.15.0"; fail=1; }
[ "$avail" = "2" ] || { echo "FAIL: $avail replicas available, expected 2"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: scout runs the fixed image with two replicas"
exit "$fail"
