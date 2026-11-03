#!/usr/bin/env bash
# Check: two scout pods run with a restricted-compliant security context.
set -uo pipefail

pods="$(kubectl -n dockyard get pods -l app=scout -o json 2>/dev/null || true)"
n="$(echo "$pods" | jq '[.items[] | select(.status.phase=="Running" and .metadata.deletionTimestamp==null)] | length')"
if [ "${n:-0}" != "2" ]; then
  echo "FAIL: $n running scout pods, expected 2"
  exit 1
fi
bad="$(echo "$pods" | jq '[.items[] | select(.metadata.deletionTimestamp==null) | select(
  ((.spec.containers[0].securityContext.privileged // false) == true)
  or ((.spec.containers[0].securityContext.allowPrivilegeEscalation // true) != false)
  or ((.spec.securityContext.runAsNonRoot // .spec.containers[0].securityContext.runAsNonRoot // false) != true)
  or ((.spec.containers[0].securityContext.runAsUser // .spec.securityContext.runAsUser // 0) == 0)
  or ((.spec.containers[0].securityContext.capabilities.drop // []) | index("ALL") | not)
  or ((.spec.securityContext.seccompProfile.type // .spec.containers[0].securityContext.seccompProfile.type // "") != "RuntimeDefault")
)] | length')"
if [ "${bad:-1}" != "0" ]; then
  echo "FAIL: $bad scout pods do not meet the restricted settings (non-root numeric user, no privilege escalation, not privileged, drop ALL, RuntimeDefault seccomp)"
  exit 1
fi
echo "PASS: both scout pods run with restricted settings"
