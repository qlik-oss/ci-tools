#!/bin/bash -l
set -eo pipefail

GH_OWNER=${GITHUB_REPOSITORY#/*}   # Strip repo
GH_REPO=${GITHUB_REPOSITORY#*/}   # Strip owner
VERSION=${VERSION#v}  # Strip v prefix as a precaution
TAG="v${VERSION}"
BRANCH_TO_RELEASE_FROM=${BRANCH_TO_RELEASE_FROM:=""}

EVENT_TO_TRIGGER="draft-release"

if ! echo $VERSION | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    # Not a release, maybe a merge to default branch (pragmatic check until code is using proper golang "backing")
    if [[ "${GITHUB_REF}" == "refs/heads/main" ]] || [[ "${GITHUB_REF}" == "refs/heads/master" ]]; then
      EVENT_TO_TRIGGER="verify-compliance"
    else
      echo "This is not a release tag or a push to default branch, skip."
      exit 0
    fi
fi


if [[ "${EVENT_TO_TRIGGER}" == "verify-compliance" ]]; then
  body_template='{"event_type":"%s","client_payload":{"target_owner":"%s","target_name":"%s","target_ref":"%s","target_version":"%s","verification_types":"%s"}}'
  body=$(printf $body_template "$EVENT_TO_TRIGGER" "$GH_OWNER" "$GH_REPO" "$GITHUB_REF" "$VERSION" "all")
else
  body_template='{"event_type":"%s","client_payload":{"repository":"%s","tag":"%s","branch_to_release_from":"%s"}}'
  body=$(printf $body_template "$EVENT_TO_TRIGGER" "$GH_REPO" "$TAG" "$BRANCH_TO_RELEASE_FROM")
fi


# This block should be removed when GH_PAT is no longer used by any client workflows
if [ -z "${GITHUB_TOKEN}" ]; then
  GITHUB_TOKEN=${GH_PAT}
fi

curl -i --fail --location --request POST "${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/dispatches" \
    --header "Authorization: token ${GITHUB_TOKEN}" \
    --header "Content-Type: application/json" \
    --data "${body}"
