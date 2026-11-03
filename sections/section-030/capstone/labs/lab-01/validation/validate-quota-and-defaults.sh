#!/usr/bin/env bash
# Check: bay has a ResourceQuota (6 pods, 500m CPU requests, 512Mi memory
# requests) and a LimitRange with container defaults.
set -uo pipefail

fail=0
q="$(kubectl -n bay get resourcequota -o json 2>/dev/null | jq '[.items[] | select(.spec.hard.pods=="6" and .spec.hard["requests.cpu"]=="500m" and .spec.hard["requests.memory"]=="512Mi")] | length')"
[ "${q:-0}" -ge 1 ] || { echo "FAIL: no ResourceQuota in bay has pods=6, requests.cpu=500m and requests.memory=512Mi"; fail=1; }
l="$(kubectl -n bay get limitrange -o json 2>/dev/null | jq '[.items[].spec.limits[] | select(.type=="Container" and .defaultRequest.cpu=="50m" and .defaultRequest.memory=="64Mi" and .default.memory=="128Mi")] | length')"
[ "${l:-0}" -ge 1 ] || { echo "FAIL: no LimitRange in bay has container defaults cpu=50m, memory=64Mi and limit memory=128Mi"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: quota and default limits exist in bay"
exit "$fail"
