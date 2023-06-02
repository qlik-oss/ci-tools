#!/usr/bin/env bash

VERSION_FILE=${VERSION_FILE:="/workspace/version.txt"}
GITHUB_WORKFLOW="qr_pipeline.yaml"

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
  TARGET_REF=refs/tags/${TAG_NAME}
else
  REF=${GIT_BRANCH}
  TARGET_REF=refs/heads/${GIT_BRANCH}
fi

generate_post_data()
{
  cat <<EOF
{
  "ref": "${REF}",
  "inputs": {
    "target_ref": "${TARGET_REF}",
    "version": "${VERSION}"
  }
}
EOF
}

echo "Data:"
generate_post_data
curl -i --fail --location --request POST "https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPONAME}/actions/workflows/${GITHUB_WORKFLOW}/dispatches" \
  --header "Authorization: token ${GH_ACCESS_TOKEN}" \
  --header "Content-Type: application/json" \
  --header "X-GitHub-Api-Version: 2022-11-28" \
  --header "Accept: application/vnd.github.v3+json" \
  --data "$(generate_post_data)"
