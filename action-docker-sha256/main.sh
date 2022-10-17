#!/bin/bash -l
set -euo pipefail

DOCKER_DEV_REGISTRY=${DOCKER_DEV_REGISTRY:=hub.docker.com}

if [ -n "$DOCKER_DEV_PASSWORD" ]; then
  echo "==> Docker registry login"
  echo "$DOCKER_DEV_PASSWORD" | docker login -u "$DOCKER_DEV_USERNAME" --password-stdin "$DOCKER_DEV_REGISTRY"
fi

IMAGE=${DOCKER_DEV_REGISTRY}/${INPUT_IMAGE_NAME}:${INPUT_IMAGE_TAG}
echo calculating sha256 for $IMAGE
docker pull $IMAGE
DOCKER_SHA256=$(docker inspect $IMAGE | jq -r '(.[].RepoDigests[0] | split(":"))[1]')

# Set GitHub Action environment and output variable
# DOCKER_SHA256
echo "DOCKER_SHA256=${DOCKER_SHA256}" >> $GITHUB_ENV
echo "DOCKER_SHA256=${DOCKER_SHA256}" >> $GITHUB_OUTPUT
