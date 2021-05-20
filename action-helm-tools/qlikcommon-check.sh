#!/bin/env bash
set -eo pipefail

# Credit https://stackoverflow.com/a/37939589/1331719
function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }
function majorminor { echo "$@" | awk -F. '{ printf("%d%03d\n", $1,$2); }'; }

echo "==> Checking Resource Contract compliance"

LATEST_QLIKCOMMON_VERSION=$(curl -s "https://api.github.com/repos/qlik-trial/resource-contract/releases/latest" -H "Authorization: Bearer $GITHUB_TOKEN" | jq -r '.tag_name' | cut -c 2-)
CURRENT_QLIKCOMMON_VERSION=$(helm inspect chart "$CHART_DIR" | yq e '.dependencies[] | select(.name == "qlikcommon") | .version' -)

if [ -z "$CURRENT_QLIKCOMMON_VERSION" ]; then

  echo "::warning ::The chart must be converted to Resource Contract"

elif [ $(majorminor $CURRENT_QLIKCOMMON_VERSION) -lt $(majorminor $LATEST_QLIKCOMMON_VERSION) ]; then

  MSG="You must update qlikcommon $CURRENT_QLIKCOMMON_VERSION to $LATEST_QLIKCOMMON_VERSION or it will fail production approval"
  # Allow if major.minor don't match due to dependency updater
  if [[ "${DEPENDENCY_UPDATE}" == "true" ]]; then
    echo "::warning ::$MSG"
  else
    echo "::error ::$MSG"
    exit 1
  fi

elif [ $(version $CURRENT_QLIKCOMMON_VERSION) -lt $(version $LATEST_QLIKCOMMON_VERSION) ]; then

  echo "::warning ::Dependency qlikcommon $CURRENT_QLIKCOMMON_VERSION is outdated, update to latest $LATEST_QLIKCOMMON_VERSION version"

else

  echo "qlikcommon:$CURRENT_QLIKCOMMON_VERSION is up to date ✔"

fi
