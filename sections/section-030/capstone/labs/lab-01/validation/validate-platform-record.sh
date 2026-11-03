#!/usr/bin/env bash
# Check: the ConfigMap platform-record in bay states the settings that are
# live: pod-security, quota-pods and deployer.
set -uo pipefail

cm="$(kubectl -n bay get configmap platform-record -o json 2>/dev/null || true)"
[ -n "$cm" ] || { echo "FAIL: ConfigMap platform-record not found in bay"; exit 1; }
fail=0
ps="$(echo "$cm" | jq -r '.data["pod-security"] // ""')"
qp="$(echo "$cm" | jq -r '.data["quota-pods"] // ""')"
dp="$(echo "$cm" | jq -r '.data.deployer // ""')"
live_ps="$(kubectl get namespace bay -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' 2>/dev/null || true)"
live_qp="$(kubectl -n bay get resourcequota -o json 2>/dev/null | jq -r '[.items[].spec.hard.pods // empty] | first // ""')"
[ -n "$live_ps" ] && [ "$ps" = "$live_ps" ] || { echo "FAIL: pod-security is '$ps', live enforce level is '$live_ps'"; fail=1; }
[ -n "$live_qp" ] && [ "$qp" = "$live_qp" ] || { echo "FAIL: quota-pods is '$qp', live quota is '$live_qp'"; fail=1; }
[ "$dp" = "bay-team" ] || { echo "FAIL: deployer is '$dp', expected 'bay-team'"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: platform-record matches the live settings"
exit "$fail"
