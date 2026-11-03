#!/usr/bin/env bash
# Check: the Deployment records why it changed (kubernetes.io/change-cause) and
# its history holds at least two revisions.
set -uo pipefail

fail=0
cause="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null | jq -r '.metadata.annotations["kubernetes.io/change-cause"] // ""')"
if [ -z "${cause// /}" ]; then
  echo "FAIL: the annotation kubernetes.io/change-cause is missing or empty on deployment scout"
  fail=1
fi

revisions="$(kubectl -n starfleet get replicasets -l app=scout -o json 2>/dev/null | jq '[.items[] | select(.metadata.annotations["deployment.kubernetes.io/revision"] != null)] | length')"
if [ "${revisions:-0}" -lt 2 ]; then
  echo "FAIL: the history has ${revisions:-0} revisions, expected at least 2"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: change cause recorded ('$cause') and $revisions revisions kept"
fi
exit "$fail"
