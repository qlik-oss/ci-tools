#!/bin/bash -l
set -euo pipefail

if ! echo $GITHUB_REF | grep -E 'refs/tags/v[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "This is not a release tag, skip."
    exit 0
else
    VERSION=${GITHUB_REF##*/}
fi

GH_REPO=${GITHUB_REPOSITORY#*/}

body_template='{"event_type":"pre-release","client_payload":{"repository":"%s","tag":"%s"}}'
body=$(printf $body_template "$GH_REPO" "$VERSION")

curl --location --request POST "${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/dispatches" \
    --header "Authorization: token ${GH_PAT}" \
    --header "Content-Type: application/json" \
    --data ${body}
