#!/bin/bash -l
set -eo pipefail

source $SCRIPT_DIR/common.sh

install_kubectl
install_helm
install_yq
setup_kind
setup_tiller

echo "==> Deploy chart $CHART_NAME"
kubectl create namespace $CHART_NAME

if [ -z "$K8S_DOCKER_REGISTRY" ]; then
    K8S_DOCKER_REGISTRY=$(yq r "${CHART_DIR}/values.yaml" 'image.registry')
    [ -z "$K8S_DOCKER_REGISTRY" ] && echo "::error file=${CHART_DIR}/values.yaml::Cannot get image.registry"
fi

if [ -z "$K8S_DOCKER_REGISTRY_SECRET" ]; then
    K8S_DOCKER_REGISTRY_SECRET=$(yq r "${CHART_DIR}/values.yaml" 'imagePullSecrets[0].name')
fi

if [[ -n "$K8S_DOCKER_REGISTRY_SECRET" ]]; then
    kubectl create secret docker-registry --namespace $CHART_NAME $K8S_DOCKER_REGISTRY_SECRET \
        --docker-server=$K8S_DOCKER_REGISTRY --docker-username=$ARTIFACTORY_USERNAME \
        --docker-password=$ARTIFACTORY_PASSWORD --docker-email=$K8S_DOCKER_EMAIL
fi

[ -f "$CHART_DIR/tests/ci-values.yaml" ] && CI_VALUES="-f ${CHART_DIR}/tests/ci-values.yaml"

runthis "helm install $CHART_NAME-$VERSION.tgz --name $CHART_NAME --namespace $CHART_NAME $CI_VALUES $EXTRA_HELM_CMD"

sleep 30
check_helm_deployment
