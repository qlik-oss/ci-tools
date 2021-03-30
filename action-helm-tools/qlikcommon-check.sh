#!/bin/env bash
set -eo pipefail

function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

echo "==> Checking Resource Contract compliance"

LATEST_QLIKCOMMON_VERSION=$(helm inspect chart qlik/qlikcommon | yq e '.version' -)
CURRENT_QLIKCOMMON_VERSION=$(helm inspect chart "$CHART_DIR" | yq e '.dependencies[] | select(.name == "qlikcommon") | .version' -)

if [ -z "$CURRENT_QLIKCOMMON_VERSION" ]; then
  echo "::warning ::The chart must be converted to Resource Contract"
elif [ $(version $CURRENT_QLIKCOMMON_VERSION) -lt $(version $LATEST_QLIKCOMMON_VERSION) ]; then
  echo "::warning ::Dependency qlikcommon $CURRENT_QLIKCOMMON_VERSION is outdated, update to latest $LATEST_QLIKCOMMON_VERSION version"
else
  echo "qlikcommon:$CURRENT_QLIKCOMMON_VERSION is up to date ✔"
fi
