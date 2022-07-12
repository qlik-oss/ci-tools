#!/bin/bash -l
set -eo pipefail

source $SCRIPT_DIR/common.sh
get_component_properties

export HELM_EXPERIMENTAL_OCI=1

echo "==> Publish to GHCR"

echo "====> Saving chart $CHART_NAME:$VERSION"
helm chart save $CHART_NAME-$VERSION.tgz $QLIK_HELM_DEV_REGISTRY/$CHART_NAME:$VERSION

echo "====> Pushing chart $CHART_NAME:$VERSION to GHCR"
helm chart push $QLIK_HELM_DEV_REGISTRY/$CHART_NAME:$VERSION
echo "====> Chart $CHART_NAME:$VERSION pushed to GHCR"

echo "====> Inspecting chart $CHART_NAME:$VERSION (to simplify debugging if needed)"
helm inspect $CHART_NAME:$VERSION
