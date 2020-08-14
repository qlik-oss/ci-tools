#!/bin/bash -l
set -eo pipefail

source $SCRIPT_DIR/common.sh

install_kubectl
install_helm
setup_kind
setup_tiller

echo "==> Deploy chart $CHART_NAME"
kubectl create namespace $CHART_NAME

if [[ -n "$K8S_DOCKER_REGISTRY_SECRET" ]]; then
    kubectl create secret docker-registry --namespace $CHART_NAME $K8S_DOCKER_REGISTRY_SECRET \
        --docker-server=$K8S_DOCKER_REGISTRY --docker-username=$ARTIFACTORY_USERNAME \
        --docker-password=$ARTIFACTORY_PASSWORD --docker-email=$K8S_DOCKER_EMAIL
fi

helm install $CHART_NAME-$VERSION.tgz --name $CHART_NAME --namespace $CHART_NAME $EXTRA_HELM_CMD

sleep 30
check_helm_deployment
