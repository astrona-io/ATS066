#!/usr/bin/env bash
# Check: two relay pods run with restricted settings and read the token by
# reference.
set -uo pipefail

pods="$(kubectl -n bay get pods -l app=relay -o json 2>/dev/null || true)"
n="$(echo "$pods" | jq '[.items[] | select(.status.phase=="Running" and .metadata.deletionTimestamp==null)] | length')"
[ "${n:-0}" = "2" ] || { echo "FAIL: $n running relay pods, expected 2"; exit 1; }
bad="$(echo "$pods" | jq '[.items[] | select(.metadata.deletionTimestamp==null) | select(
  ((.spec.containers[0].securityContext.privileged // false) == true)
  or ((.spec.containers[0].securityContext.allowPrivilegeEscalation // true) != false)
  or ((.spec.securityContext.runAsNonRoot // .spec.containers[0].securityContext.runAsNonRoot // false) != true)
  or ((.spec.containers[0].securityContext.runAsUser // .spec.securityContext.runAsUser // 0) == 0)
  or ((.spec.containers[0].securityContext.capabilities.drop // []) | index("ALL") | not)
  or ((.spec.securityContext.seccompProfile.type // .spec.containers[0].securityContext.seccompProfile.type // "") != "RuntimeDefault")
)] | length')"
fail=0
[ "${bad:-1}" = "0" ] || { echo "FAIL: $bad relay pods do not meet the restricted settings"; fail=1; }
ref="$(kubectl -n bay get deployment relay -o json 2>/dev/null | jq '[.spec.template.spec.containers[0].env[]? | select(.name=="RELAY_TOKEN") | .valueFrom.secretKeyRef | select(.name=="relay-token" and .key=="token")] | length')"
[ "${ref:-0}" = "1" ] || { echo "FAIL: RELAY_TOKEN does not use secretKeyRef relay-token/token"; fail=1; }
leak="$(kubectl -n bay get configmaps -o json 2>/dev/null | jq '[.items[].data // {} | to_entries[] | select(.value | contains("cadet-52b8e0"))] | length')"
[ "${leak:-0}" = "0" ] || { echo "FAIL: a ConfigMap holds the token value"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: relay runs restricted and reads its token by reference"
exit "$fail"
