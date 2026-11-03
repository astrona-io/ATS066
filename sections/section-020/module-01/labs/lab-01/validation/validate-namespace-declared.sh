#!/usr/bin/env bash
# Check: the namespace hangar exists with the label managed-by=opentofu.
set -uo pipefail

label="$(kubectl get namespace hangar -o jsonpath='{.metadata.labels.managed-by}' 2>/dev/null || true)"
if ! kubectl get namespace hangar >/dev/null 2>&1; then
  echo "FAIL: namespace hangar not found"
  exit 1
fi
if [ "$label" != "opentofu" ]; then
  echo "FAIL: namespace hangar has label managed-by='$label', expected 'opentofu'"
  exit 1
fi
echo "PASS: namespace hangar exists with managed-by=opentofu"
