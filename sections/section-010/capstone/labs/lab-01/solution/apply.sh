#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl diff -k "$DIR/files/overlays/outpost" || true
kubectl apply -k "$DIR/files/overlays/outpost"
kubectl -n outpost rollout status deployment/scout --timeout=300s

# The old ConfigMap with a fixed name is not used any more.
kubectl -n outpost delete configmap scout-settings

config_map="$(kubectl -n outpost get configmaps -o json | jq -r '.items[] | select(.metadata.name | test("^scout-settings-[a-z0-9]{10}$")) | .metadata.name')"
revision="$(kubectl -n outpost get deployment scout -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}')"
observed="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

kubectl apply -f - <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: release-evidence
  namespace: outpost
data:
  config-map: "${config_map}"
  revision: "${revision}"
  observed-at: "${observed}"
  replicas: "3"
YAML
echo "[solution] Applied."
