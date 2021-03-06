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

if [ -z "${CIRCLE_TAG}" ]; then
  if [ -z "${CIRCLE_BRANCH##*released*}" ]; then
    echo "Skipping ${GITHUB_WORKFLOW} on release branches: ${CIRCLE_BRANCH}"
    exit 0
  fi
fi

if [ -n "${CIRCLE_TAG}" ]; then
  REF=${CIRCLE_TAG}
else
  REF=${CIRCLE_BRANCH}
fi

body_template='{"ref":"%s","inputs":{"version":"%s"}}'
body=$(printf $body_template "$REF" "$VERSION")
echo "Using ${body}"

curl --fail --location --request POST "https://api.github.com/repos/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/actions/workflows/${GITHUB_WORKFLOW}/dispatches" \
  --header "Authorization: token ${GH_ACCESS_TOKEN}" \
  --header "Content-Type: application/json" \
  --header "Accept: application/vnd.github.v3+json" \
  --data "${body}"
