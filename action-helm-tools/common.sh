#!/bin/bash -l
set -eo pipefail

# Defaults
export HELM_REPO=${HELM_REPO:="helm-dev"}
export HELM_VIRTUAL_REPO=${HELM_VIRTUAL_REPO:="qlikhelm"}
export HELM_LOCAL_REPO=${HELM_LOCAL_REPO:="qlik"}
export K8S_DOCKER_EMAIL=${K8S_DOCKER_EMAIL:="xyz@example.com"}

# Tools
export HELM_VERSION=${HELM_VERSION:="2.14.3"}
export KUBECTL_VERSION=${KUBECTL_VERSION:="1.15.4"}
export KIND_VERSION=${KIND_VERSION:="v0.8.1"}
# Get Image version from https://github.com/kubernetes-sigs/kind/releases, look for K8s version in the release notes
export KIND_IMAGE=${KIND_IMAGE:="kindest/node:v1.15.11@sha256:6cc31f3533deb138792db2c7d1ffc36f7456a06f1db5556ad3b6927641016f50"}
export YQ_VERSION="3.3.4"

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

setup_tiller() {
    echo "==> Instal tiller"
    install_helm
    kubectl create serviceaccount tiller --namespace kube-system --save-config --dry-run --output=yaml | kubectl apply -f -
    kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin \
        --serviceaccount=kube-system:tiller --save-config --dry-run --output=yaml | kubectl apply -f -
    helm init --service-account tiller --upgrade --wait
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
