#!/usr/bin/env bash
# Check: a ResourceQuota in starfleet limits pods to 6, CPU requests to 500m
# and memory requests to 512Mi.
set -uo pipefail

quotas="$(kubectl -n starfleet get resourcequota -o json 2>/dev/null || true)"
ok="$(echo "$quotas" | jq '[.items[] | select(.spec.hard.pods=="6" and .spec.hard["requests.cpu"]=="500m" and .spec.hard["requests.memory"]=="512Mi")] | length')"
if [ "${ok:-0}" -lt 1 ]; then
  echo "FAIL: no ResourceQuota in starfleet has pods=6, requests.cpu=500m and requests.memory=512Mi"
  exit 1
fi
echo "PASS: a ResourceQuota with the required ceilings exists"
