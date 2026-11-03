#!/usr/bin/env bash
# Check: the namespace, the ConfigMap and the Deployment carry the label
# managed-by=opentofu from the OpenTofu files.
set -uo pipefail

fail=0
ns="$(kubectl get namespace hangar -o jsonpath='{.metadata.labels.managed-by}' 2>/dev/null || true)"
cm="$(kubectl -n hangar get configmap hangar-settings -o jsonpath='{.metadata.labels.managed-by}' 2>/dev/null || true)"
dep="$(kubectl -n hangar get deployment beacon -o jsonpath='{.metadata.labels.managed-by}' 2>/dev/null || true)"
[ "$ns" = "opentofu" ] || { echo "FAIL: namespace hangar has managed-by='$ns', expected 'opentofu'"; fail=1; }
[ "$cm" = "opentofu" ] || { echo "FAIL: ConfigMap hangar-settings has managed-by='$cm', expected 'opentofu'"; fail=1; }
[ "$dep" = "opentofu" ] || { echo "FAIL: Deployment beacon has managed-by='$dep', expected 'opentofu'"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: all three objects carry managed-by=opentofu"
exit "$fail"
