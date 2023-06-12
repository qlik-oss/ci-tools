#!/usr/bin/env bash

VERSION_FILE=${VERSION_FILE:="/workspace/version.txt"}
REGISTRY=${REGISTRY:="ghcr.io/qlik-trial"}
OPERATION=${OPERATION:="sign"}
IMAGE_NAME=${IMAGE_NAME:="$CIRCLE_PROJECT_REPONAME"}


if [ -z "${VERSION}" ]; then
  VERSION=$(cat "$VERSION_FILE")
fi

# Final check that version is set
if [ -z "${VERSION}" ]; then
  echo "ERROR: VERSION could not be determined"
  echo "If version file is in different location than ${VERSION_FILE}"
  echo "before running github_workflow_dispatch.sh script, set a variable:"
  echo "export VERSION_FILE=/path/version.txt"
  echo "or set VERSION variable directly'"
  echo 'export VERSION="$(node|cat ...)"'
  exit 1
fi

IMAGE=${REGISTRY}/${IMAGE_NAME}:${VERSION}
SHA256=$(docker inspect $IMAGE | jq -r '(.[].RepoDigests[0] | split(":"))[1]')

if [ -z "$SHA256" ]; then
  echo "Could not find image sha, aborting"
  exit 1
fi

generate_post_data()
{
  cat <<EOF
{
  "event_type": "cosign",
  "client_payload": {
    "operation": "${OPERATION}",
    "registry": "${REGISTRY}",
    "image_name": "${IMAGE_NAME}",
    "image_version": "${VERSION}",
    "sha256": "${SHA256}"
  }
}
EOF
}

echo "Data:"
generate_post_data

curl -i --fail --location --request POST https://api.github.com/repos/qlik-trial/qlik-releaser/dispatches \
  --header "Authorization: token ${GH_ACCESS_TOKEN}" \
  --header "Content-Type: application/json" \
  --header "X-GitHub-Api-Version: 2022-11-28" \
  --header "Accept: application/vnd.github.v3+json" \
  --data "$(generate_post_data)"
