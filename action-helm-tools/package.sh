#!/bin/bash -l
set -eo pipefail

source $SCRIPT_DIR/common.sh

yaml_lint

install_helm

helm init --client-only
echo "==> Helm add repo"
helm repo add $HELM_LOCAL_REPO $REGISTRY/$HELM_VIRTUAL_REPO --username $ARTIFACTORY_USERNAME --password $ARTIFACTORY_PASSWORD
helm repo update

echo "==> Resource contract compliance test"
export LATEST_QLIKCOMMON_VERSION=$(helm inspect chart qlik/qlikcommon | yq r - 'version')
check_resource_contract_compliance

echo "==> Helm dependency build"
helm dependency build $CHART_DIR

echo "==> Linting"
helm lint $CHART_DIR

echo "==> Helm package"
helm package $CHART_DIR --version $VERSION --app-version $VERSION
