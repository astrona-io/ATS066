#!/usr/bin/env bash
# Check: The ConfigMap scout-settings holds mode careful and release-pipeline owns the field.
set -uo pipefail

cm="$(kubectl -n hold get configmap scout-settings --show-managed-fields -o json 2>/dev/null || true)"
[ -n "$cm" ] || { echo "FAIL: configmap scout-settings not found in namespace hold"; exit 1; }
fail=0
mode="$(echo "$cm" | jq -r '.data.mode // ""')"
[ "$mode" = "careful" ] || { echo "FAIL: data.mode is '$mode', expected 'careful'"; fail=1; }
n="$(echo "$cm" | jq '[.metadata.managedFields[] | select(.manager == "release-pipeline" and .operation == "Apply")] | length')"
[ "$n" -ge 1 ] || { echo "FAIL: release-pipeline does not own fields of configmap scout-settings"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: scout-settings has mode careful and is owned by release-pipeline"
exit "$fail"
