#!/usr/bin/env bash
# Check: Every ready endpoint of the Service belongs to a green pod, and there are two.
set -uo pipefail

fail=0
ips="$(kubectl -n launch get endpointslices -l kubernetes.io/service-name=scout -o json 2>/dev/null | jq -r '[.items[].endpoints[]? | select(.conditions.ready == true) | .addresses[]] | sort | .[]')"
n="$(echo "$ips" | grep -c . || true)"
[ "$n" = "2" ] || { echo "FAIL: $n ready endpoints, expected 2"; fail=1; }
for ip in $ips; do
  v="$(kubectl -n launch get pods -o json | jq -r --arg ip "$ip" '[.items[] | select(.status.podIP == $ip) | .metadata.labels.version][0] // ""')"
  [ "$v" = "green" ] || { echo "FAIL: endpoint $ip belongs to a pod with version '$v'"; fail=1; }
done
[ "$fail" -eq 0 ] && echo "PASS: only green pods are behind the Service"
exit "$fail"
