#!/bin/bash -l
set -eo pipefail

export HELM_VERSION=${HELM_VERSION:="2.14.3"}
export KUBECTL_VERSION=${KUBECTL_VERSION:="1.15.4"}
export K3S_VERSION=${K3S_VERSION:="v0.9.1"}
export K3D_WAIT=${K3D_WAIT:="90"}
export K3D_NAME=${K3D_NAME:="test"}

install_k3d(){
    echo "==> Get k3d"
    curl -s https://raw.githubusercontent.com/rancher/k3d/master/install.sh | bash
}

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

create_k3d_cluster() {
    echo "==> Create K3s cluster"
    k3d create --name $K3D_NAME --image rancher/k3s:$K3S_VERSION --wait $K3D_WAIT
    export KUBECONFIG="$(k3d get-kubeconfig --name=$K3D_NAME)"
}

echorun() {
    # Print cmd before running it
    echo "$@"
    eval "$@"
}
