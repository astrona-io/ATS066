#!/usr/bin/env bash
# Starting state: staging and production run scout with the good image. Then a
# failed release is pushed to production: an image that does not exist. The
# old production pods keep serving and a new pod cannot pull its image.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n staging rollout status deployment/scout --timeout=240s
kubectl -n production rollout status deployment/scout --timeout=240s
kubectl -n production set image deployment/scout scout=ghcr.io/stefanprodan/podinfo:0.0.0-does-not-exist
echo "[lab] Ready."
