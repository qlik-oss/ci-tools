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

echo "==> Merging serviceUris"
yq '.serviceUris' < dependencies.yaml >file1.yaml
cat file1.yaml
yq '.configs.data' < $CHART_DIR/values.yaml >file2.yaml
cat file2.yaml
yq file1.yaml file2.yaml >serviceUris.yaml
cat serviceUris.yaml
yq -i '.configs.data |= load("serviceUris.yaml")' "$CHART_DIR/values.yaml"

echo "==> Merging component metadata"
yq -i '.component |= load("component.yaml")' "$CHART_DIR/values.yaml"

if [ "$IMAGE_TAG_UPDATE" = "false" ]; then
  echo "==> Skip updating image.tag due to IMAGE_TAG_UPDATE=$IMAGE_TAG_UPDATE"
else
  echo "==> Update image.tag"
  yq e --inplace '.image.tag |= env(VERSION)' "$CHART_DIR/values.yaml"
fi

echo "==> Linting"
runthis "helm lint $CHART_DIR --with-subcharts"

echo "==> Helm package"
runthis "helm package $CHART_DIR --version $VERSION --app-version $VERSION"
