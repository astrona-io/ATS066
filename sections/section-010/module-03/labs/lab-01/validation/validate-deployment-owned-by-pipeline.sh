#!/usr/bin/env bash
# Check: The Deployment scout has fields that the field manager release-pipeline set with an apply operation.
set -uo pipefail

dep="$(kubectl -n hold get deployment scout --show-managed-fields -o json 2>/dev/null || true)"
[ -n "$dep" ] || { echo "FAIL: deployment scout not found in namespace hold"; exit 1; }
n="$(echo "$dep" | jq '[.metadata.managedFields[] | select(.manager == "release-pipeline" and .operation == "Apply")] | length')"
if [ "$n" -ge 1 ]; then echo "PASS: release-pipeline owns fields of deployment scout"; exit 0; fi
echo "FAIL: no managedFields entry with manager release-pipeline and operation Apply on deployment scout"
exit 1
