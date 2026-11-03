#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`. It reaches the
# end state of the OpenTofu files with kubectl patches that keep the objects
# (same unique identifiers), as an import and apply would.
set -euo pipefail

kubectl label namespace hangar managed-by=opentofu --overwrite
kubectl -n hangar label configmap hangar-settings managed-by=opentofu --overwrite
kubectl -n hangar label deployment beacon managed-by=opentofu --overwrite
kubectl -n hangar patch configmap hangar-settings --type=merge -p '{"data":{"mode":"active","owner":"platform"}}'
kubectl -n hangar scale deployment beacon --replicas=2
kubectl -n hangar rollout status deployment/beacon --timeout=240s
echo "[solution] Applied."
