#!/usr/bin/env bash
# Check: The Deployment scout-green has two available replicas, the label version=green, a readiness probe and the message green release.
set -uo pipefail

dep="$(kubectl -n launch get deployment scout-green -o json 2>/dev/null || true)"
[ -n "$dep" ] || { echo "FAIL: deployment scout-green not found in namespace launch"; exit 1; }
fail=0
avail="$(echo "$dep" | jq '.status.availableReplicas // 0')"
lab="$(echo "$dep" | jq -r '.spec.template.metadata.labels.version // ""')"
probe="$(echo "$dep" | jq '[.spec.template.spec.containers[]? | select(.readinessProbe != null)] | length')"
msg="$(echo "$dep" | jq -r '[.spec.template.spec.containers[0].env[]? | select(.name == "PODINFO_UI_MESSAGE") | .value][0] // ""')"
[ "$avail" = "2" ] || { echo "FAIL: $avail replicas available, expected 2"; fail=1; }
[ "$lab" = "green" ] || { echo "FAIL: pod label version is '$lab', expected 'green'"; fail=1; }
[ "$probe" -ge 1 ] || { echo "FAIL: no container has a readiness probe"; fail=1; }
[ "$msg" = "green release" ] || { echo "FAIL: PODINFO_UI_MESSAGE is '$msg', expected 'green release'"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: scout-green is deployed and ready"
exit "$fail"
