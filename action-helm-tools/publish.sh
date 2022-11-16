#!/bin/bash -l
set -eo pipefail

source $SCRIPT_DIR/common.sh
get_component_properties

echo "==> Publish to GHCR"

echo "====> Pushing chart $CHART_NAME:$VERSION to $HELM_DEV_REGISTRY"
helm push $CHART_NAME-$VERSION.tgz $HELM_DEV_REGISTRY/$CHART_NAME:$VERSION
echo "====> Chart $CHART_NAME:$VERSION pushed to $HELM_DEV_REGISTRY"
