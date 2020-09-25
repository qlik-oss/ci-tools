#!/bin/bash -l
set -eo pipefail

source $SCRIPT_DIR/common.sh

yaml_lint

install_helm

helm init --client-only
echo "==> Helm add repo"
helm repo add $HELM_LOCAL_REPO $REGISTRY/$HELM_VIRTUAL_REPO --username $ARTIFACTORY_USERNAME --password $ARTIFACTORY_PASSWORD
helm repo update

export LATEST_QLIKCOMMON_VERSION=$(helm inspect chart qlik/qlikcommon | yq r - 'version')
$SCRIPT_DIR/resource-contract/dist/check-compliance.js

echo "==> Helm dependency build"
helm dependency build $CHART_DIR

echo "==> Linting"
helm lint $CHART_DIR

echo "==> Update image tag"
install_yq
yq write --inplace $CHART_DIR/values.yaml image.tag $VERSION

echo "==> Helm package"
helm package $CHART_DIR --version $VERSION --app-version $VERSION
