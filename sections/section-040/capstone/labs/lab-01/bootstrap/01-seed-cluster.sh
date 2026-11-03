#!/usr/bin/env bash
# Starting state: preview and live run relay with the good image. A failed
# release has been pushed to live: an image that does not exist. No record,
# no pipeline identity and no release label exist.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n preview rollout status deployment/relay --timeout=240s
kubectl -n live rollout status deployment/relay --timeout=240s
kubectl -n live set image deployment/relay relay=ghcr.io/stefanprodan/podinfo:0.0.0-does-not-exist
echo "[lab] Ready."
