#!/usr/bin/env bash
# Check: Both Deployments name their runbook in an annotation.
set -uo pipefail

fail=0
for name in scout probe; do
  rb="$(kubectl -n ops get deployment "$name" -o json 2>/dev/null | jq -r '.metadata.annotations.runbook // ""')"
  [ "$rb" = "runbooks/$name.md" ] || { echo "FAIL: $name annotation runbook is '$rb', expected 'runbooks/$name.md'"; fail=1; }
done
[ "$fail" -eq 0 ] && echo "PASS: both Deployments name their runbook"
exit "$fail"
