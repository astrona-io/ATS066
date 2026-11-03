#!/usr/bin/env bash
# Check: The policy no-latest-tag and a binding of the same name exist, and the binding denies.
set -uo pipefail

fail=0
pol="$(kubectl get validatingadmissionpolicy no-latest-tag -o json 2>/dev/null || true)"
[ -n "$pol" ] || { echo "FAIL: ValidatingAdmissionPolicy no-latest-tag not found"; fail=1; }
bind="$(kubectl get validatingadmissionpolicybinding no-latest-tag -o json 2>/dev/null || true)"
if [ -z "$bind" ]; then
  echo "FAIL: ValidatingAdmissionPolicyBinding no-latest-tag not found"; fail=1
else
  p="$(echo "$bind" | jq -r '.spec.policyName')"
  deny="$(echo "$bind" | jq '[.spec.validationActions[]? | select(. == "Deny")] | length')"
  [ "$p" = "no-latest-tag" ] || { echo "FAIL: the binding refers to policy '$p'"; fail=1; }
  [ "$deny" -ge 1 ] || { echo "FAIL: the binding does not use the action Deny"; fail=1; }
fi
[ "$fail" -eq 0 ] && echo "PASS: policy and denying binding exist"
exit "$fail"
