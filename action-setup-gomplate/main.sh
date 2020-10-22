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

echo "Installing Gomplate ${INPUT_GOMPLATE_VERSION}"

sudo curl --fail -sL "https://github.com/hairyhenderson/gomplate/releases/download/v${INPUT_GOMPLATE_VERSION}/gomplate_${PLATFORM}-amd64-slim" -o /usr/local/bin/gomplate && \
    sudo chmod +x /usr/local/bin/gomplate

gomplate --version
