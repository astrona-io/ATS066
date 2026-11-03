#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution: waits until scout
# has two available replicas.
set -euo pipefail

kubectl -n starfleet rollout status deployment/scout --timeout=120s
echo "[testing] settled."
