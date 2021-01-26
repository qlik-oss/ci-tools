#!/bin/bash
set -euo pipefail

# Required env variables:
# VERSION - subchart version to be updated
# CHART_NAME - subchart name
# DESTINATION_CHART_DIR
# REGISTRY - url to helm registry
# ARTIFACTORY_USERNAME
# ARTIFACTORY_PASSWORD

# TODO:
# - Input param to bump major, minor or (default) patch version of the target chart

HELM_VIRTUAL_REPO=${HELM_VIRTUAL_REPO:=qlikhelm}
HELM_LOCAL_REPO=${HELM_LOCAL_REPO:=qlik}

if [ -z "$VERSION" ]; then
    echo "Error: VERSION is not defined"
    exit 1
fi

export HELM_VERSION=${HELM_VERSION:="3.4.0"}
curl -L "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" | tar xvz
chmod +x linux-amd64/helm
mv linux-amd64/helm /usr/local/bin/helm

echo "==> Helm add repo"
helm repo add "$HELM_LOCAL_REPO" "$REGISTRY/$HELM_VIRTUAL_REPO" --username "$ARTIFACTORY_USERNAME" --password "$ARTIFACTORY_PASSWORD"
helm repo update

# Bump subchart requirement version
yq write --inplace "$DESTINATION_CHART_DIR/requirements.yaml" "dependencies.(name==$CHART_NAME).version" "$VERSION"

echo "==> Helm dependency update"
helm dependency update "$DESTINATION_CHART_DIR"
