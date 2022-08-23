#!/bin/bash -l
set -eo pipefail

source $SCRIPT_DIR/common.sh

install_yq
get_component_properties
yaml_lint
add_helm_repos

$SCRIPT_DIR/qlikcommon-check.sh

echo "==> Helm dependency build"
helm dependency build "$CHART_DIR"

echo "==> Merging component metadata"
yq -i '.component |= load("component.yaml")' "$CHART_DIR/values.yaml"

if [ "$IMAGE_TAG_UPDATE" = "false" ]; then
  echo "==> Skip updating image.tag due to IMAGE_TAG_UPDATE=$IMAGE_TAG_UPDATE"
else
  echo "==> Update image.tag"
  yq e --inplace '.image.tag |= env(VERSION)' "$CHART_DIR/values.yaml"
fi

if [ "$SKIP_LINT" = "true" ]; then
  echo "==> Skip linting due to SKIP_LINT=$SKIP_LINT"
else
  echo "==> Linting"
  runthis "helm lint $CHART_DIR --with-subcharts"
fi

echo "==> Helm package"
runthis "helm package $CHART_DIR --version $VERSION --app-version $VERSION"
