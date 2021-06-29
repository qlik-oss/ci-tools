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
    fi
fi

if [[ -n "$CUSTOM_ACTIONS" ]]; then
  echo "==> Running custom actions"
  echo "${CUSTOM_ACTIONS}"
  eval "${CUSTOM_ACTIONS}"
fi

# Install a dependency chart (e.g. CRDs) before installing the main chart
if [[ -n "$INIT_CHART" ]]; then
  runthis "helm install init $INIT_CHART"
fi

# Add any helm cli arguments when installing chart
if [[ -n "$EXTRA_HELM_CMD" ]]; then
  options+=("$EXTRA_HELM_CMD")
fi

# If tests/ci-values.yaml exits in the same folder as chart use that values file
if [[ -f "$CHART_DIR/tests/ci-values.yaml" ]]; then
  options+=(-f "${CHART_DIR}/tests/ci-values.yaml")
fi

# For CI testing, clustered nats-streaming is not required and this saves ~1 min of runner time
if [[ "${SINGLE_NATS_STREAMING:=true}" == "true" ]]; then
  options+=(-f "${SCRIPT_DIR}/helmvalues/messaging-non-clustered.yaml")
fi

runthis "helm install $CHART_NAME $CHART_NAME-$VERSION.tgz --namespace $CHART_NAME --create-namespace $EXTRA_HELM_CMD" "${options[@]}"

sleep 30
check_helm_deployment
