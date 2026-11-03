#!/usr/bin/env bash
# Starting state: the namespace depot and the ConfigMap depot-settings, made by
# hand. Their unique identifiers go into the ConfigMap capstone-seed-record, so
# the grader can tell an import from a delete and create.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl create -f "$DIR/manifests/depot-by-hand.yaml"
namespace_uid="$(kubectl get namespace depot -o jsonpath='{.metadata.uid}')"
configmap_uid="$(kubectl -n depot get configmap depot-settings -o jsonpath='{.metadata.uid}')"
kubectl -n default create configmap capstone-seed-record \
  --from-literal=namespace-uid="$namespace_uid" \
  --from-literal=configmap-uid="$configmap_uid"
echo "[lab] Ready."
