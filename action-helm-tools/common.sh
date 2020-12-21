#!/bin/bash -l
set -eo pipefail

# Defaults
export HELM_REPO=${HELM_REPO:="helm-dev"}
export HELM_VIRTUAL_REPO=${HELM_VIRTUAL_REPO:="qlikhelm"}
export HELM_LOCAL_REPO=${HELM_LOCAL_REPO:="qlik"}
export K8S_DOCKER_EMAIL=${K8S_DOCKER_EMAIL:="xyz@example.com"}

# Tools
export HELM_VERSION=${HELM_VERSION:="3.4.0"}
export KUBECTL_VERSION=${KUBECTL_VERSION:="1.16.15"}
export KIND_VERSION=${KIND_VERSION:="v0.9.0"}
# Get Image version from https://github.com/kubernetes-sigs/kind/releases, look for K8s version in the release notes
export KIND_IMAGE=${KIND_IMAGE:="kindest/node:v1.16.15@sha256:a89c771f7de234e6547d43695c7ab047809ffc71a0c3b65aa54eda051c45ed20"}
export YQ_VERSION="3.3.4"

get_component_properties() {
    install_yq

    # Get chartname
    export CHART_NAME
    if [ -z "$CHART_NAME" ]; then
        CHART_NAME=$(yq r components.yaml 'components[0].componentId-helm')
        if [ -z "$CHART_NAME" ]; then
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
        K8S_DOCKER_REGISTRY_SECRET=$(yq r "${CHART_DIR}/values.yaml" 'image.pullSecrets[0].name')
        [ -z "$K8S_DOCKER_REGISTRY_SECRET" ] && K8S_DOCKER_REGISTRY_SECRET=$(yq r "${CHART_DIR}/values.yaml" 'imagePullSecrets[0].name')
    fi

    export K8S_DOCKER_REGISTRY
    if [ -z "$K8S_DOCKER_REGISTRY" ]; then
        K8S_DOCKER_REGISTRY=$(yq r "${CHART_DIR}/values.yaml" 'image.registry')
        if [ -z "$K8S_DOCKER_REGISTRY" ]; then
            echo "::error file=${CHART_DIR}/values.yaml::Cannot get image.registry from values.yaml"
            exit 1
        fi
    fi
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

check_helm_deployment() {
    echo "==> Check helm deployment"
    DEPLOY_TIMEOUT=${DEPLOY_TIMEOUT:-300}
    "$SCRIPT_DIR/helm-deployment-check.sh" --release $CHART_NAME --namespace $CHART_NAME -t $DEPLOY_TIMEOUT
}

install_jfrog() {
    if ! command -v jfrog; then
        echo "==> Installing jfrog cli"
        curl -Lso ./jfrog https://api.bintray.com/content/jfrog/jfrog-cli-go/\$latest/jfrog-cli-linux-amd64/jfrog?bt_package=jfrog-cli-linux-amd64
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
    kind create cluster --image ${KIND_IMAGE}
}

yaml_lint() {
    echo "==> YAML lint"
    if ! command -v yamllint; then
        sudo pip install yamllint
    fi

    yamllint -c "$SCRIPT_DIR/default.yamllint" $CHART_DIR
}

install_yq() {
    if ! command -v yq || [[ $(yq --version 2>&1 | cut -d ' ' -f3) != "${YQ_VERSION}" ]] ; then
        echo "==> Get yq:${YQ_VERSION}"
        sudo curl -Ls https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/yq_linux_amd64 -o /usr/local/bin/yq
        sudo chmod +x /usr/local/bin/yq
    fi
}

runthis() {
    echo "$@"
    eval "$@"
}
