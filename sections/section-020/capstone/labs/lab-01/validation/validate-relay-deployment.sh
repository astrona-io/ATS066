#!/usr/bin/env bash
# Check: Deployment relay has 2 replicas, all available, the pinned image,
# envFrom of depot-settings, the label managed-by=opentofu and exactly 2 pods
# that are not terminating (the manual scale to 3 was reverted).
set -uo pipefail

dep="$(kubectl -n depot get deployment relay -o json 2>/dev/null || true)"
if [ -z "$dep" ]; then
  echo "FAIL: Deployment relay not found in depot"
  exit 1
fi
fail=0
desired="$(echo "$dep" | jq '.spec.replicas')"
available="$(echo "$dep" | jq '.status.availableReplicas // 0')"
image="$(echo "$dep" | jq -r '.spec.template.spec.containers[] | select(.name=="relay") | .image')"
ref="$(echo "$dep" | jq -r '[.spec.template.spec.containers[] | select(.name=="relay") | .envFrom[]? | .configMapRef.name] | join(",")')"
label="$(echo "$dep" | jq -r '.metadata.labels["managed-by"] // ""')"
pods="$(kubectl -n depot get pods -l app=relay -o json 2>/dev/null | jq '[.items[] | select(.metadata.deletionTimestamp == null)] | length')"
[ "$desired" = "2" ] || { echo "FAIL: spec.replicas is $desired, expected 2"; fail=1; }
[ "$available" = "2" ] || { echo "FAIL: availableReplicas is $available, expected 2"; fail=1; }
[ "$image" = "ghcr.io/stefanprodan/podinfo:6.15.0" ] || { echo "FAIL: image is '$image', expected ghcr.io/stefanprodan/podinfo:6.15.0"; fail=1; }
[ "$ref" = "depot-settings" ] || { echo "FAIL: envFrom ConfigMaps are '$ref', expected depot-settings"; fail=1; }
[ "$label" = "opentofu" ] || { echo "FAIL: label managed-by is '$label', expected 'opentofu'"; fail=1; }
[ "${pods:-0}" = "2" ] || { echo "FAIL: found ${pods:-0} relay pods, expected 2"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: relay runs 2 available replicas and reads depot-settings"
exit "$fail"
