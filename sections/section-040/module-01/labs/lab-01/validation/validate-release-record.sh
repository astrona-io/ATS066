#!/usr/bin/env bash
# Check: ConfigMap release-scout in starfleet holds version, digest,
# source-revision rev-0042 and approved-by.
set -uo pipefail

cm="$(kubectl -n starfleet get configmap release-scout -o json 2>/dev/null || true)"
[ -n "$cm" ] || { echo "FAIL: ConfigMap release-scout not found in starfleet"; exit 1; }
fail=0
for key in version digest approved-by; do
  v="$(echo "$cm" | jq -r --arg k "$key" '.data[$k] // ""')"
  [ -n "$v" ] || { echo "FAIL: key $key is missing or empty"; fail=1; }
done
rev="$(echo "$cm" | jq -r '.data["source-revision"] // ""')"
[ "$rev" = "rev-0042" ] || { echo "FAIL: source-revision is '$rev', expected 'rev-0042'"; fail=1; }
dg="$(echo "$cm" | jq -r '.data.digest // ""')"
case "$dg" in sha256:*) ;; "") ;; *) echo "FAIL: digest '$dg' does not start with sha256:"; fail=1 ;; esac
[ "$fail" -eq 0 ] && echo "PASS: release-scout holds the release facts"
exit "$fail"
