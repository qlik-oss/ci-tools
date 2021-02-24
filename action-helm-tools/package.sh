#!/bin/bash -l
set -eo pipefail

source $SCRIPT_DIR/common.sh

install_yq
get_component_properties
yaml_lint
add_helm_repos

export LATEST_QLIKCOMMON_VERSION=$(helm inspect chart qlik/qlikcommon | yq e '.version' -)
$SCRIPT_DIR/resource-contract/dist/check-compliance.js

echo "==> Helm dependency build"
helm dependency build "$CHART_DIR"

echo "==> Update image tag"
yq e --inplace '.image.tag |= env(VERSION)' "$CHART_DIR/values.yaml"

echo "==> Linting"
runthis "helm lint $CHART_DIR --with-subcharts"

echo "==> Helm package"
runthis "helm package $CHART_DIR --version $VERSION --app-version $VERSION"
