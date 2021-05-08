#!/bin/bash -l
set -eo pipefail

# Defaults
export HELM_REPO=${HELM_REPO:="helm-dev"}
export HELM_VIRTUAL_REPO=${HELM_VIRTUAL_REPO:="qlikhelm"}
export HELM_LOCAL_REPO=${HELM_LOCAL_REPO:="qlik"}
export K8S_DOCKER_EMAIL=${K8S_DOCKER_EMAIL:="xyz@example.com"}
export DEPENDENCY_UPDATE=${DEPENDENCY_UPDATE:="false"}

# Tools
export HELM_VERSION=${HELM_VERSION:="3.5.4"}
export KUBECTL_VERSION=${KUBECTL_VERSION:="1.18.15"}
export KIND_VERSION=${KIND_VERSION:="v0.10.0"}
# Get Image version from https://github.com/kubernetes-sigs/kind/releases, look for K8s version in the release notes
export KIND_IMAGE=${KIND_IMAGE:="kindest/node:v1.18.15@sha256:5c1b980c4d0e0e8e7eb9f36f7df525d079a96169c8a8f20d8bd108c0d0889cc4"}
export YQ_VERSION="4.6.0"

get_component_properties() {
    install_yq

    # Get chartname
    export CHART_NAME
    if [ -z "$CHART_NAME" ]; then
        CHART_NAME=$(yq e '.components[0].componentId-helm' components.yaml)
        if [[ "$CHART_NAME" == "null" ]]; then
            CHART_NAME=$(yq e '.components[0].componentId' components.yaml)  # Default is componentId
        fi
        if [[ "$CHART_NAME" == "null" ]]; then
            echo "::error file=components.yaml::Cannot get componentId-helm from components.yaml"
            exit 1
        fi
    fi

    # Set chartpath
    export CHART_DIR
    [ -z "$CHART_DIR" ] && CHART_DIR="manifests/chart/${CHART_NAME}"

    # Get K8S registry pull secret name and registry
    export K8S_DOCKER_REGISTRY_SECRET
    if [ -z "$K8S_DOCKER_REGISTRY_SECRET" ]; then
        K8S_DOCKER_REGISTRY_SECRET=$(yq e '.image.pullSecrets[0].name' "${CHART_DIR}/values.yaml")
        [ "$K8S_DOCKER_REGISTRY_SECRET" = "null" ] && K8S_DOCKER_REGISTRY_SECRET=$(yq e '.imagePullSecrets[0].name' "${CHART_DIR}/values.yaml")
    fi

    export K8S_DOCKER_REGISTRY
    if [ -z "$K8S_DOCKER_REGISTRY" ]; then
        K8S_DOCKER_REGISTRY=$(yq e '.image.registry' "${CHART_DIR}/values.yaml")
        if [ "$K8S_DOCKER_REGISTRY" = "null" ]; then
            echo "::error file=${CHART_DIR}/values.yaml::Cannot get image.registry from values.yaml"
            exit 1
        fi
    fi

    export CHART_APIVERSION
    CHART_APIVERSION="$(helm inspect chart "$CHART_DIR" | yq e '.apiVersion' -)"
}

install_kubectl() {
    echo "==> Get kubectl:${KUBECTL_VERSION}"
    curl -LsO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
}

get_helm() {
    echo "==> Get helm:${HELM_VERSION}"
    curl -Ls "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" | tar xvz
    chmod +x linux-amd64/helm
    sudo mv linux-amd64/helm /usr/local/bin/helm
}

install_helm() {
    if ! command -v helm; then
        echo "Helm is missing"
        get_helm
    elif ! [[ $(helm version --short -c) == *${HELM_VERSION}* ]]; then
        echo "Helm $(helm version --short -c) is not desired version"
        get_helm
    fi
}

add_helm_repos() {
  export HELM_EXPERIMENTAL_OCI=1
  install_helm
  get_component_properties

  public_repos=(
    "bitnami https://charts.bitnami.com/bitnami"
    "minio https://helm.min.io/"
    "dandydev https://dandydeveloper.github.io/charts"
    "stable https://charts.helm.sh/stable"
  )

  if [ -n "$GHCR_HELM_DEV_REGISTRY" ]; then
    echo "==> Helm registry login"
    echo $GHCR_HELM_DEV_PASSWORD | helm registry login --username $GHCR_HELM_DEV_USERNAME --password-stdin https://$GHCR_HELM_DEV_REGISTRY
  fi
  echo "==> Helm add repo"
  echo "helm repo add $HELM_LOCAL_REPO $REGISTRY/$HELM_VIRTUAL_REPO --username $ARTIFACTORY_USERNAME --password $ARTIFACTORY_PASSWORD"
  helm repo add $HELM_LOCAL_REPO $REGISTRY/$HELM_VIRTUAL_REPO --username $ARTIFACTORY_USERNAME --password $ARTIFACTORY_PASSWORD
  for repo in "${public_repos[@]}"; do
    IFS=" " read -r -a arr <<< "${repo}"
      helm repo add "${arr[0]}" "${arr[1]}"
  done
  helm repo update
}

check_helm_deployment() {
    echo "==> Check helm deployment"
    DEPLOY_TIMEOUT=${DEPLOY_TIMEOUT:-300}
    "$SCRIPT_DIR/helm-deployment-check.sh" --release $CHART_NAME --namespace $CHART_NAME -t $DEPLOY_TIMEOUT
}

install_jfrog() {
    if ! command -v jfrog; then
        echo "==> Installing jfrog cli"
        curl -fL https://getcli.jfrog.io | sh
        chmod +x ./jfrog
        sudo mv ./jfrog /usr/local/bin/jfrog
    fi
}

install_kind() {
    echo "==> Get KIND:${KIND_VERSION}"
    curl -Lso ./kind https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
}

setup_kind() {
    echo "==> Setting up KIND (Kubernetes in Docker)"
    if ! command -v kind; then
        install_kind
    fi

    clusters=$(kind get clusters -q)

    if [ -z "$clusters" ]; then
      kind create cluster --image ${KIND_IMAGE} --name ${CHART_NAME}
    else
      echo "KIND cluster already exist, continue"
    fi
}

yaml_lint() {
    echo "==> YAML lint"
    if ! command -v yamllint; then
        sudo pip install yamllint
    fi

    yamllint -c "$SCRIPT_DIR/default.yamllint" $CHART_DIR -f parsable
}

install_yq() {
    if ! command -v yq || [[ $(yq --version 2>&1 | cut -d ' ' -f3) != "${YQ_VERSION}" ]] ; then
        echo "==> Get yq:${YQ_VERSION}"
        sudo curl -Ls https://github.com/mikefarah/yq/releases/download/v$YQ_VERSION/yq_linux_amd64 -o /usr/local/bin/yq
        sudo chmod +x /usr/local/bin/yq
    fi
}

runthis() {
    echo "$@"
    eval "$@"
}
