#!/usr/bin/env bash
# Check: A Deployment with the tag latest is rejected and one with a version tag is accepted, both in dock.
set -uo pipefail

fail=0
rejected=0
for i in $(seq 1 10); do
  if ! kubectl -n dock create deployment gate-check --image=ghcr.io/stefanprodan/podinfo:latest --dry-run=server -o name >/dev/null 2>&1; then rejected=1; break; fi
  sleep 2
done
[ "$rejected" -eq 1 ] || { echo "FAIL: a Deployment with the tag latest was accepted in dock"; fail=1; }
if ! kubectl -n dock create deployment gate-check --image=ghcr.io/stefanprodan/podinfo:6.15.0 --dry-run=server -o name >/dev/null 2>&1; then
  echo "FAIL: a Deployment with the tag 6.15.0 was rejected in dock"; fail=1
fi
[ "$fail" -eq 0 ] && echo "PASS: latest is rejected and 6.15.0 is accepted"
exit "$fail"
