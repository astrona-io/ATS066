#!/usr/bin/env bash
# Check: the ConfigMap release-evidence matches the live cluster: the generated
# ConfigMap name, the current Deployment revision, a UTC time and 3 replicas.
set -uo pipefail

evidence="$(kubectl -n outpost get configmap release-evidence -o json 2>/dev/null || true)"
if [ -z "$evidence" ]; then
  echo "FAIL: ConfigMap release-evidence not found in outpost"
  exit 1
fi

fail=0
live_config="$(kubectl -n outpost get configmaps -o json 2>/dev/null | jq -r '[.items[] | select(.metadata.name | test("^scout-settings-[a-z0-9]{10}$")) | .metadata.name][0] // ""')"
live_revision="$(kubectl -n outpost get deployment scout -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}' 2>/dev/null || true)"

recorded_config="$(echo "$evidence" | jq -r '.data["config-map"] // ""')"
if [ -z "$live_config" ] || [ "$recorded_config" != "$live_config" ]; then
  echo "FAIL: config-map is '$recorded_config', expected the live generated name '$live_config'"
  fail=1
fi

recorded_revision="$(echo "$evidence" | jq -r '.data.revision // ""')"
if [ -z "$live_revision" ] || [ "$recorded_revision" != "$live_revision" ]; then
  echo "FAIL: revision is '$recorded_revision', expected the live revision '$live_revision'"
  fail=1
fi

observed="$(echo "$evidence" | jq -r '.data["observed-at"] // ""')"
if ! echo "$observed" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$'; then
  echo "FAIL: observed-at is '$observed', expected a UTC time like 2026-11-03T10:15:00Z"
  fail=1
fi

replicas="$(echo "$evidence" | jq -r '.data.replicas // ""')"
if [ "$replicas" != "3" ]; then
  echo "FAIL: replicas is '$replicas', expected 3"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: release-evidence records $live_config, revision $live_revision and 3 replicas"
fi
exit "$fail"
