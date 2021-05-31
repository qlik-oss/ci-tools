#!/bin/bash -l
set -eo pipefail

source $SCRIPT_DIR/common.sh

install_kubectl
install_helm
install_yq
get_component_properties
setup_kind

echo "==> Deploy chart $CHART_NAME"
kubectl create namespace $CHART_NAME

if [[ -n "$K8S_DOCKER_REGISTRY_SECRET" ]]; then
    if [[ -n "$GHCR_DOCKER_DEV_REGISTRY" ]] && [[ "$K8S_DOCKER_REGISTRY" == "$GHCR_DOCKER_DEV_REGISTRY" ]]; then
        echo "====> GHCR docker registry"
        kubectl create secret docker-registry --namespace $CHART_NAME $K8S_DOCKER_REGISTRY_SECRET \
            --docker-server=$K8S_DOCKER_REGISTRY --docker-username=$GHCR_DOCKER_DEV_USERNAME \
            --docker-password=$GHCR_DOCKER_DEV_PASSWORD --docker-email=$K8S_DOCKER_EMAIL
    else
        echo "====> Artifactory docker registry"
        kubectl create secret docker-registry --namespace $CHART_NAME $K8S_DOCKER_REGISTRY_SECRET \
            --docker-server=$K8S_DOCKER_REGISTRY --docker-username=$ARTIFACTORY_USERNAME \
            --docker-password=$ARTIFACTORY_PASSWORD --docker-email=$K8S_DOCKER_EMAIL
    fi
fi

if [[ -n "$CUSTOM_ACTIONS" ]]; then
  echo "==> Running custom actions"
  echo "${CUSTOM_ACTIONS}"
  eval "${CUSTOM_ACTIONS}"
fi

if [[ -n "$INIT_CHART" ]]; then
  runthis "helm install init $INIT_CHART"
fi

[ -f "$CHART_DIR/tests/ci-values.yaml" ] && CI_VALUES="-f ${CHART_DIR}/tests/ci-values.yaml"

runthis "helm install $CHART_NAME $CHART_NAME-$VERSION.tgz --namespace $CHART_NAME --create-namespace $CI_VALUES $EXTRA_HELM_CMD"

sleep 30
check_helm_deployment
