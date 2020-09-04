ARG KUSTOMIZE_VERSION=v0.0.43
ARG ARGOCD_VERSION=latest

FROM argoproj/argocd:${ARGOCD_VERSION}

USER root

RUN apt-get update && \
    apt-get install -y \
        gpg \
        wget && \
    wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y powershell && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Replace kustomize
RUN wget -qO- https://github.com/qlik-oss/kustomize/releases/download/qlik%2F${KUSTOMIZE_VERSION}/kustomize_qlik_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz | tar -xvzf - && \
    chmod +x kustomize && mv kustomize /usr/local/bin/

USER argocd
