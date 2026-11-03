#!/usr/bin/env bash
# Check: Service relay selects app=relay, exposes port 80 to target port 9898
# and carries managed-by=opentofu.
set -uo pipefail

svc="$(kubectl -n depot get service relay -o json 2>/dev/null || true)"
if [ -z "$svc" ]; then
  echo "FAIL: Service relay not found in depot"
  exit 1
fi
fail=0
selector="$(echo "$svc" | jq -r '.spec.selector.app // ""')"
port="$(echo "$svc" | jq -r '.spec.ports[0].port // ""')"
target="$(echo "$svc" | jq -r '.spec.ports[0].targetPort // ""')"
label="$(echo "$svc" | jq -r '.metadata.labels["managed-by"] // ""')"
[ "$selector" = "relay" ] || { echo "FAIL: selector app is '$selector', expected 'relay'"; fail=1; }
[ "$port" = "80" ] || { echo "FAIL: port is '$port', expected 80"; fail=1; }
[ "$target" = "9898" ] || { echo "FAIL: targetPort is '$target', expected 9898"; fail=1; }
[ "$label" = "opentofu" ] || { echo "FAIL: label managed-by is '$label', expected 'opentofu'"; fail=1; }
endpoints="$(kubectl -n depot get endpoints relay -o json 2>/dev/null | jq '[.subsets[]?.addresses[]?] | length')"
[ "${endpoints:-0}" -ge 1 ] || { echo "FAIL: Service relay has no ready endpoints"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: Service relay selects the relay pods"
exit "$fail"
