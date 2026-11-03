#!/usr/bin/env bash
# Check: The Deployment still carries the label owner=platform.
set -uo pipefail

owner="$(kubectl -n yard get deployment relay -o json 2>/dev/null | jq -r '.metadata.labels.owner // ""')"
if [ "$owner" = "platform" ]; then echo "PASS: relay keeps owner=platform"; exit 0; fi
echo "FAIL: label owner is '$owner', expected 'platform'"
exit 1
