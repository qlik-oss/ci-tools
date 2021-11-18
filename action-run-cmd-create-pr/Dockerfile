FROM node:lts-alpine

ENV YQ_VERSION="3.3.2"

RUN apk add --update --no-cache \
    git \
    curl \
    wget \
    bash \
    python3 \
    jq

RUN curl -L https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -o /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
