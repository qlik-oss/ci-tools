#!/bin/bash -l
set -eo pipefail

export HELM_VERSION=${HELM_VERSION:="2.14.3"}
export KUBECTL_VERSION=${KUBECTL_VERSION:="1.15.4"}
export KIND_VERSION=${KIND_VERSION:="v0.8.1"}
# Get Image version from https://github.com/kubernetes-sigs/kind/releases, look for K8s version in the release notes
export KIND_IMAGE=${KIND_IMAGE:="kindest/node:v1.15.11@sha256:6cc31f3533deb138792db2c7d1ffc36f7456a06f1db5556ad3b6927641016f50"}

install_kubectl() {
    echo "==> Get kubectl:${KUBECTL_VERSION}"
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
}

get_helm() {
    echo "==> Get helm:${HELM_VERSION}"
    curl -L "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" | tar xvz
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
        curl -Lo ./jfrog https://api.bintray.com/content/jfrog/jfrog-cli-go/\$latest/jfrog-cli-linux-amd64/jfrog?bt_package=jfrog-cli-linux-amd64
        chmod +x ./jfrog
        sudo mv ./jfrog /usr/local/bin/jfrog
    fi
}

install_kind() {
    echo "==> Get KIND:${KIND_VERSION}"
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64
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
      pip install yamllint   
    fi

    yamllint -c "$SCRIPT_DIR/default.yamllint" $CHART_DIR
}

check_resource_contract_compliance () {
    echo "==> Resource contract compliance test"

    qlikcommon_version=$(yq r $CHART_DIR/requirements.yaml 'dependencies.(name==qlikcommon).version') || echo "::warning $CHART_DIR/requirements.yaml not found" | exit 0

    if [[ -z "$qlikcommon_version" ]]; then
        echo "::warning Please convert chart to use resource contract as per the standards set here: https://github.com/qlik-trial/resource-contract"
    elif [[ "$qlikcommon_version" != "$LATEST_QLIKCOMMON_VERSION" ]]; then
        echo "::warning Please update to latest qlikcommon version in requirements.yaml to $LATEST_QLIKCOMMON_VERSION"
    fi
}
