#!/bin/bash -l
set -o pipefail

if [ -n "$DOCKER_DEV_PASSWORD" ]; then
  echo "==> Docker registry login"
  echo "$DOCKER_DEV_PASSWORD" | docker login -u "$DOCKER_DEV_USERNAME" --password-stdin "$INPUT_IMAGE_REGISTRY"
fi

IMAGE=${INPUT_IMAGE_REGISTRY}/${INPUT_IMAGE_NAME}:${INPUT_IMAGE_TAG}
echo calculating sha256 for $IMAGE
docker pull $IMAGE
docker inspect $IMAGE | jq '(.[].RepoDigests[0] | split(":"))[1]'

# Set GitHub Action environment and output variable
# DOCKER_SHA256
echo "DOCKER_SHA256=${DOCKER_SHA256}" >> $GITHUB_ENV
echo "::set-output name=DOCKER_SHA256::${DOCKER_SHA256}"
