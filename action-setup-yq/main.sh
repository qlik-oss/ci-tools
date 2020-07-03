#!/bin/bash -l
set -euo pipefail

if [ "$RUNNER_OS" == "Linux" ]; then
    PLATFORM="linux"
elif [ "$RUNNER_OS" == "Linux" ]; then
    PLATFORM="darwin"
else
    echo "OS $RUNNER_OS not supported"
    exit 1
fi

echo "Installing YQ ${INPUT_YQ_VERSION}"
sudo curl -L https://github.com/mikefarah/yq/releases/download/${INPUT_YQ_VERSION}/yq_${PLATFORM}_amd64 -o /usr/local/bin/yq && \
    sudo chmod +x /usr/local/bin/yq

yq --version
