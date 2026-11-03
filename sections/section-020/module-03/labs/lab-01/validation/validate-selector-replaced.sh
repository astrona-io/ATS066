#!/usr/bin/env bash
# Check: The Deployment relay uses only the selector app.kubernetes.io/name=relay.
set -uo pipefail

dep="$(kubectl -n yard get deployment relay -o json 2>/dev/null || true)"
[ -n "$dep" ] || { echo "FAIL: deployment relay not found in namespace yard"; exit 1; }
sel="$(echo "$dep" | jq -c '.spec.selector.matchLabels')"
tpl="$(echo "$dep" | jq -r '.spec.template.metadata.labels["app.kubernetes.io/name"] // ""')"
fail=0
[ "$sel" = '{"app.kubernetes.io/name":"relay"}' ] || { echo "FAIL: selector is $sel, expected only app.kubernetes.io/name=relay"; fail=1; }
[ "$tpl" = "relay" ] || { echo "FAIL: the pod template label app.kubernetes.io/name is '$tpl', expected 'relay'"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: relay selects app.kubernetes.io/name=relay"
exit "$fail"
