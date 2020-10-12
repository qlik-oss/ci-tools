#!/bin/bash -l
set -o pipefail

RELEASE_TAG="0"
BRANCH_NAME=""

# Unshallow git repository. Do not fail in case the repository is already unshallowed.
git fetch --prune --unshallow || true

# git-describe - Give an object a human readable name based on an available ref
git_rev=$(git describe --tags --abbrev=7)

# On push event
if [ "$GITHUB_EVENT_NAME" == "push" ]; then
    _sha=$GITHUB_SHA
    echo "${GITHUB_REF}" | grep -E '^refs/heads/' && BRANCH_NAME=${GITHUB_REF##*/}
fi

# On pull_request event
if [ "$GITHUB_EVENT_NAME" == "pull_request" ]; then
    _sha=$(jq -r .pull_request.head.sha "$GITHUB_EVENT_PATH")
    BRANCH_NAME=${GITHUB_HEAD_REF}
fi

# If no version is returned from git describe, generate one
[ -z "$git_rev" ] && git_rev="v0.0.0-0-g${_sha:0:7}"

# Return Version without v prefix
VERSION=${git_rev#v}

# On tag push that matches refs/tags/v*.*.*, use that version regardless of git describe
if echo "$GITHUB_REF" | grep -E 'refs/tags/v[0-9]+\.[0-9]+\.[0-9]+$'; then
    VERSION=${GITHUB_REF#*/v}
    RELEASE_TAG="1"
fi

[ -z "$VERSION" ] && exit 1
echo "Set version: ${VERSION}"
echo "Set commit_sha: ${_sha}"
echo "Set branch_name: ${BRANCH_NAME}"

# Set GitHub Action environment and output variable
# VERSION
echo "VERSION=${VERSION}" >> $GITHUB_ENV
echo "::set-output name=VERSION::${VERSION}"

# COMMIT_SHA
echo "COMMIT_SHA=${_sha}" >> $GITHUB_ENV
echo "::set-output name=COMMIT_SHA::${_sha}"

# BRANCH_NAME
echo "BRANCH_NAME=${BRANCH_NAME}" >> $GITHUB_ENV
echo "::set-output name=BRANCH_NAME::${BRANCH_NAME}"

# RELEASE TAG
echo "RELEASE_TAG=${RELEASE_TAG}" >> $GITHUB_ENV
echo "::set-output name=RELEASE_TAG::${RELEASE_TAG}"
