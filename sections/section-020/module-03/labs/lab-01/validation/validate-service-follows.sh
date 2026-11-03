#!/usr/bin/env bash
# Check: The Service relay selects the new label and has two ready endpoints.
set -uo pipefail

svc="$(kubectl -n yard get service relay -o json 2>/dev/null || true)"
[ -n "$svc" ] || { echo "FAIL: service relay not found in namespace yard"; exit 1; }
fail=0
sel="$(echo "$svc" | jq -c '.spec.selector')"
[ "$sel" = '{"app.kubernetes.io/name":"relay"}' ] || { echo "FAIL: service selector is $sel, expected only app.kubernetes.io/name=relay"; fail=1; }
ready="$(kubectl -n yard get endpointslices -l kubernetes.io/service-name=relay -o json | jq '[.items[].endpoints[]? | select(.conditions.ready == true)] | length')"
[ "$ready" = "2" ] || { echo "FAIL: the service has $ready ready endpoints, expected 2"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: the service selects the new label and has two ready endpoints"
exit "$fail"
