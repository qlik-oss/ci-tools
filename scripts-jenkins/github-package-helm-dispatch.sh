#!/usr/bin/env bash

VERSION_FILE=${VERSION_FILE:="/workspace/version.txt"}
GITHUB_WORKFLOW=${GITHUB_WORKFLOW:="qr_package-helm-chart.yaml"}

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

if [ -z "${TAG_NAME}" ]; then
  if [ -z "${GIT_BRANCH##*released*}" ]; then
    echo "Skipping ${GITHUB_WORKFLOW} on release branches: ${GIT_BRANCH}"
    exit 0
  fi
fi

if [ "${GIT_BRANCH}" == "update_depConfig_yaml" ]; then
  echo "Skipping ${GITHUB_WORKFLOW} on branch 'update_depConfig_yaml'"
  exit 0
fi

if [ -n "${TAG_NAME}" ]; then
  REF=${TAG_NAME}
else
  REF=${GIT_BRANCH}
fi

# TODO: Remove this function when package-helm.yaml is no longer used in any component repository
generate_post_data_old()
{
  cat <<EOF
{
  "ref": "${REF}",
  "inputs": {
    "version": "${VERSION}",
    "commitsha": "${GIT_COMMIT}"
  }
}
EOF
}

generate_post_data()
{
  cat <<EOF
{
  "ref": "${REF}",
  "inputs": {
    "version": "${VERSION}",
    "commit_sha": "${GIT_COMMIT}"
  }
}
EOF
}

echo "Data:"
if [ "${GITHUB_WORKFLOW}" == "qr_package-helm-chart.yaml" ]; then
  generate_post_data
  curl -i --fail --location --request POST "https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPONAME}/actions/workflows/${GITHUB_WORKFLOW}/dispatches" \
    --header "Authorization: token ${GH_ACCESS_TOKEN}" \
    --header "Content-Type: application/json" \
    --header "Accept: application/vnd.github.v3+json" \
    --data "$(generate_post_data)"
else
  generate_post_data_old
  curl -i --fail --location --request POST "https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPONAME}/actions/workflows/${GITHUB_WORKFLOW}/dispatches" \
    --header "Authorization: token ${GH_ACCESS_TOKEN}" \
    --header "Content-Type: application/json" \
    --header "Accept: application/vnd.github.v3+json" \
    --data "$(generate_post_data_old)"
fi
