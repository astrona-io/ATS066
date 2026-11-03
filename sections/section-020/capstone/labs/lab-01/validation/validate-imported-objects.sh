#!/usr/bin/env bash
# Check: the namespace depot and the ConfigMap depot-settings keep their
# unique identifiers and carry the label managed-by=opentofu.
set -uo pipefail

record="$(kubectl -n default get configmap capstone-seed-record -o json 2>/dev/null || true)"
if [ -z "$record" ]; then
  echo "FAIL: the ConfigMap capstone-seed-record is missing from the namespace default. Do not delete it."
  exit 1
fi
fail=0
ns_uid="$(kubectl get namespace depot -o jsonpath='{.metadata.uid}' 2>/dev/null || true)"
cm_uid="$(kubectl -n depot get configmap depot-settings -o jsonpath='{.metadata.uid}' 2>/dev/null || true)"
[ "$ns_uid" = "$(echo "$record" | jq -r '.data["namespace-uid"]')" ] || { echo "FAIL: namespace depot is missing or was deleted and created again. Import it."; fail=1; }
[ "$cm_uid" = "$(echo "$record" | jq -r '.data["configmap-uid"]')" ] || { echo "FAIL: ConfigMap depot-settings is missing or was deleted and created again. Import it."; fail=1; }
ns_label="$(kubectl get namespace depot -o jsonpath='{.metadata.labels.managed-by}' 2>/dev/null || true)"
cm_label="$(kubectl -n depot get configmap depot-settings -o jsonpath='{.metadata.labels.managed-by}' 2>/dev/null || true)"
[ "$ns_label" = "opentofu" ] || { echo "FAIL: namespace depot has managed-by='$ns_label', expected 'opentofu'"; fail=1; }
[ "$cm_label" = "opentofu" ] || { echo "FAIL: ConfigMap depot-settings has managed-by='$cm_label', expected 'opentofu'"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: namespace and ConfigMap were imported and labelled"
exit "$fail"
