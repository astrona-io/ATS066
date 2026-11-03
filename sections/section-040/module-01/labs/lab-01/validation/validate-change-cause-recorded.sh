#!/usr/bin/env bash
# Check: the scout Deployment has a change-cause annotation that names rev-0042.
set -uo pipefail

cause="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null | jq -r '.metadata.annotations["kubernetes.io/change-cause"] // ""')"
if [ -z "$cause" ]; then
  echo "FAIL: no kubernetes.io/change-cause annotation on the scout Deployment"
  exit 1
fi
case "$cause" in
  *rev-0042*) echo "PASS: change cause recorded: $cause" ;;
  *) echo "FAIL: change cause '$cause' does not name rev-0042"; exit 1 ;;
esac
