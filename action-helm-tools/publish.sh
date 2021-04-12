#!/bin/bash -l
set -eo pipefail

source $SCRIPT_DIR/common.sh
get_component_properties

export JFROG_CLI_OFFER_CONFIG=false

install_jfrog

echo "==> Check published version of $CHART_NAME"

echo "==> Searching for existing chart $HELM_REPO/$CHART_NAME-$VERSION.tgz in $REGISTRY"
if jfrog rt s "$HELM_REPO/$CHART_NAME-$VERSION.tgz" --url $REGISTRY --apikey $ARTIFACTORY_PASSWORD --fail-no-op; then
    printf "$CHART_NAME-$VERSION already exist in artifactory $HELM_REPO, exit\n"
    exit 0
else
    printf "==> Attempting to upload:\n$CHART_NAME-$VERSION.tgz to $HELM_REPO $REGISTRY\n\n"
    jfrog rt u $CHART_NAME-$VERSION.tgz $HELM_REPO --url $REGISTRY --apikey $ARTIFACTORY_PASSWORD --fail-no-op || exit 1
fi
