#!/usr/bin/env bash
# Starting state: three objects made by hand in the namespace hangar. The
# script records their unique identifiers in the ConfigMap seed-record, so the
# grader can tell an import from a delete and create. It writes no OpenTofu file.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl create -f "$DIR/manifests/hangar-by-hand.yaml"
kubectl -n hangar rollout status deployment/beacon --timeout=240s

namespace_uid="$(kubectl get namespace hangar -o jsonpath='{.metadata.uid}')"
configmap_uid="$(kubectl -n hangar get configmap hangar-settings -o jsonpath='{.metadata.uid}')"
deployment_uid="$(kubectl -n hangar get deployment beacon -o jsonpath='{.metadata.uid}')"

kubectl -n default create configmap seed-record \
  --from-literal=namespace-uid="$namespace_uid" \
  --from-literal=configmap-uid="$configmap_uid" \
  --from-literal=deployment-uid="$deployment_uid"
echo "[lab] Ready."
