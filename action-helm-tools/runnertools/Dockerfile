FROM ubuntu:latest

ENV HELM_VERSION="2.14.3"
ENV KUBECTL_VERSION="1.15.11"
ENV YQ_VERSION="3.3.0"

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    git \
    curl \
    wget \
    jq \
    yamllint

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

RUN curl -L "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" | tar xvz && \
    chmod +x linux-amd64/helm && \
    mv linux-amd64/helm /usr/local/bin/helm

RUN curl -L https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -o /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

RUN mkdir -p /workspace

WORKDIR /workspace
