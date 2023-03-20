#!/bin/bash -l
set -eo pipefail

GH_OWNER=${GITHUB_REPOSITORY%/*}   # Strip repo
GH_REPO=${GITHUB_REPOSITORY#*/}   # Strip owner
VERSION=${VERSION#v}  # Strip v prefix as a precaution
TAG="v${VERSION}"
BRANCH_TO_RELEASE_FROM=${BRANCH_TO_RELEASE_FROM:=""}

if ! echo $VERSION | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "This is not a release tag or a push to default branch, skip."
  exit 0
fi

body_template='{"event_type":"%s","client_payload":{"repository":"%s","tag":"%s","branch_to_release_from":"%s"}}'
body=$(printf $body_template "draft-release" "$GH_REPO" "$TAG" "$BRANCH_TO_RELEASE_FROM")

# This block should be removed when GH_PAT is no longer used by any client workflows
if [ -z "${GITHUB_TOKEN}" ]; then
  GITHUB_TOKEN=${GH_PAT}
fi

curl -i --fail --location --request POST "${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/dispatches" \
    --header "Authorization: token ${GITHUB_TOKEN}" \
    --header "Content-Type: application/json" \
    --data "${body}"
