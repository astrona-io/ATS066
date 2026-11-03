#!/usr/bin/env bash
# Check: ConfigMap release-relay in live holds version r3, source-revision
# rev-0107, an approver and the digest that the live pods report; and the
# Deployment names rev-0107 in its change cause.
set -uo pipefail

cm="$(kubectl -n live get configmap release-relay -o json 2>/dev/null || true)"
[ -n "$cm" ] || { echo "FAIL: ConfigMap release-relay not found in live"; exit 1; }
fail=0
ver="$(echo "$cm" | jq -r '.data.version // ""')"
rev="$(echo "$cm" | jq -r '.data["source-revision"] // ""')"
who="$(echo "$cm" | jq -r '.data["approved-by"] // ""')"
dg="$(echo "$cm" | jq -r '.data.digest // ""')"
[ "$ver" = "r3" ] || { echo "FAIL: version is '$ver', expected 'r3'"; fail=1; }
[ "$rev" = "rev-0107" ] || { echo "FAIL: source-revision is '$rev', expected 'rev-0107'"; fail=1; }
[ -n "$who" ] || { echo "FAIL: approved-by is empty"; fail=1; }
live="$(kubectl -n live get pods -l app=relay -o json 2>/dev/null | jq -r '[.items[] | select(.metadata.deletionTimestamp==null and .status.phase=="Running") | .status.containerStatuses[0].imageID // ""][0] // ""')"
live="${live##*@}"
[ -n "$dg" ] && [ "$dg" = "$live" ] || { echo "FAIL: digest is '$dg', live pods report '$live'"; fail=1; }
cause="$(kubectl -n live get deployment relay -o json 2>/dev/null | jq -r '.metadata.annotations["kubernetes.io/change-cause"] // ""')"
case "$cause" in *rev-0107*) ;; *) echo "FAIL: change cause '$cause' does not name rev-0107"; fail=1 ;; esac
[ "$fail" -eq 0 ] && echo "PASS: the release record and the change cause match live"
exit "$fail"
