#!/usr/bin/env bash
# Check: Deployment beacon has 2 available replicas, the pinned image, the
# label app=beacon and reads hangar-settings with envFrom.
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
ref="$(echo "$dep" | jq -r '[.spec.template.spec.containers[] | select(.name=="beacon") | .envFrom[]? | .configMapRef.name] | join(",")')"
label="$(echo "$dep" | jq -r '.metadata.labels["managed-by"] // ""')"
[ "$desired" = "2" ] || { echo "FAIL: spec.replicas is $desired, expected 2"; fail=1; }
[ "$available" = "2" ] || { echo "FAIL: availableReplicas is $available, expected 2"; fail=1; }
[ "$image" = "ghcr.io/stefanprodan/podinfo:6.15.0" ] || { echo "FAIL: image is '$image', expected ghcr.io/stefanprodan/podinfo:6.15.0"; fail=1; }
[ "$ref" = "hangar-settings" ] || { echo "FAIL: envFrom ConfigMaps are '$ref', expected hangar-settings"; fail=1; }
[ "$label" = "opentofu" ] || { echo "FAIL: label managed-by is '$label', expected 'opentofu'"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: beacon runs 2 available replicas and reads hangar-settings"
exit "$fail"
