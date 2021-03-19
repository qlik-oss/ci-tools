#!/usr/bin/env bash

VERSION_FILE=${VERSION_FILE:="/workspace/version.txt"}
GITHUB_WORKFLOW=${GITHUB_WORKFLOW:="package-helm.yaml"}

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

TAG_TO_USE=CIRCLE_TAG  # Circle CI
if [ -z "${TAG_TO_USE}" ]; then
  TAG_TO_USE=${TAG_NAME}  # Jenkins
fi

BRANCH_TO_USE=CIRCLE_BRANCH  # Circle CI
if [ -z "${BRANCH_TO_USE}" ]; then
  BRANCH_TO_USE=${GIT_BRANCH}  # Jenkins
fi

if [ -z "${TAG_TO_USE}" ]; then
  if [ -z "${BRANCH_TO_USE##*released*}" ]; then
    echo "Skipping ${GITHUB_WORKFLOW} on release branches: ${BRANCH_TO_USE}"
    exit 0
  fi
fi

if [ -n "${TAG_TO_USE}" ]; then
  REF=${TAG_TO_USE}
else
  REF=${BRANCH_TO_USE}
fi

body_template='{"ref":"%s","inputs":{"version":"%s"}}'
body=$(printf $body_template "$REF" "$VERSION")
echo "Using ${body}"

curl --fail --location --request POST "https://api.github.com/repos/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/actions/workflows/${GITHUB_WORKFLOW}/dispatches" \
  --header "Authorization: token ${GH_ACCESS_TOKEN}" \
  --header "Content-Type: application/json" \
  --header "Accept: application/vnd.github.v3+json" \
  --data "${body}"
