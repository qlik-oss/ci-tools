#!/bin/bash -l
set -eo pipefail

source $SCRIPT_DIR/common.sh
get_component_properties

export HELM_EXPERIMENTAL_OCI=1

echo "==> Push chart $CHART_NAME:$VERSION to GHCR"
helm push "$CHART_NAME-$VERSION.tgz" "oci://$QLIK_HELM_DEV_REGISTRY"
echo "==> Chart $CHART_NAME:$VERSION pushed to GHCR"
