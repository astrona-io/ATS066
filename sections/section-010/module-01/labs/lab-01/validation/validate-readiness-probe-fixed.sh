#!/usr/bin/env bash
# Check: the pod template of scout has an HTTP readiness probe on /readyz and
# still uses the original image. Rejects removing the probe, which would hide
# the problem instead of fixing it.
set -uo pipefail

container="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null | jq -c '.spec.template.spec.containers[] | select(.name=="scout")')"
if [ -z "$container" ]; then
  echo "FAIL: container scout not found in the pod template"
  exit 1
fi

fail=0
path="$(echo "$container" | jq -r '.readinessProbe.httpGet.path // ""')"
if [ "$path" != "/readyz" ]; then
  echo "FAIL: the readiness probe path is '$path', expected /readyz"
  fail=1
fi

image="$(echo "$container" | jq -r '.image')"
if [ "$image" != "ghcr.io/stefanprodan/podinfo:6.15.0" ]; then
  echo "FAIL: scout runs image '$image', expected ghcr.io/stefanprodan/podinfo:6.15.0"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: the readiness probe checks /readyz and the image is unchanged"
fi
exit "$fail"
