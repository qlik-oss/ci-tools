#!/bin/bash -l
set -euo pipefail

GH_REPO=${GITHUB_REPOSITORY#*/}

if ! echo $VERSION | grep -E "^[0-9]+\.[0-9]+\.[0-9]+$"; then
    echo "Version: $VERSION does not match semver for release version of X.Y.Z"
    exit 1
fi

body_template='{"event_type":"pre-release","client_payload":{"repository":"%s","tag":"%s"}}'
body=$(printf $body_template "$GH_REPO" "$VERSION")

curl --location --request POST "${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/dispatches" \
    --header "Authorization: token ${GH_PAT}" \
    --header "Content-Type: application/json" \
    --data ${body}
