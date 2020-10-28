#!/bin/bash -l
set -eo pipefail

source $SCRIPT_DIR/common.sh

public_repos=(
    "bitnami https://charts.bitnami.com/bitnami"
)

install_yq
get_component_properties
yaml_lint
install_helm

helm init --client-only
echo "==> Helm add repo"
helm repo add $HELM_LOCAL_REPO $REGISTRY/$HELM_VIRTUAL_REPO --username $ARTIFACTORY_USERNAME --password $ARTIFACTORY_PASSWORD
for repo in "${public_repos[@]}"; do
	IFS=" " read -r -a arr <<< "${repo}"
    helm repo add "${arr[0]}" "${arr[1]}"
done
helm repo update

export LATEST_QLIKCOMMON_VERSION=$(helm inspect chart qlik/qlikcommon | yq r - 'version')
$SCRIPT_DIR/resource-contract/dist/check-compliance.js

echo "==> Helm dependency build"
helm dependency build $CHART_DIR

echo "==> Update image tag"
yq write --inplace $CHART_DIR/values.yaml image.tag $VERSION

echo "==> Helm package"
runthis "helm package $CHART_DIR --version $VERSION --app-version $VERSION"

echo "==> Linting"
helm lint $CHART_DIR-$VERSION.tgz
