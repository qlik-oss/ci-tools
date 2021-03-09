#!/bin/bash -l
set -eo pipefail

# Strip v prefix
VERSION=${VERSION#v}

if ! echo $VERSION | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "This is not a release tag, skip."
    exit 0
fi

VERSION="v${VERSION}"

GH_REPO=${GITHUB_REPOSITORY#*/}

BRANCH_TO_RELEASE_FROM=${BRANCH_TO_RELEASE_FROM:=""}

body_template='{"event_type":"pre-release","client_payload":{"repository":"%s","tag":"%s","branch_to_release_from":"%s"}}'
body=$(printf $body_template "$GH_REPO" "$VERSION" "$BRANCH_TO_RELEASE_FROM")

# This block should be removed when GH_PAT is no longer used by any client workflows
if [ -z "${GITHUB_TOKEN}" ]; then
  GITHUB_TOKEN=${GH_PAT}
fi

curl --fail --location --request POST "${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/dispatches" \
    --header "Authorization: token ${GITHUB_TOKEN}" \
    --header "Content-Type: application/json" \
    --data ${body}
