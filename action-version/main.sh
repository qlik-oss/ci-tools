#!/bin/bash -l
set -o pipefail

# Get tags, latest release and its commit sha
git fetch --depth=1 origin +refs/tags/*:refs/tags/* || true

# Try to get latest v*.*.* tag
latest_release_tag=$(git tag -l --sort=-v:refname | egrep '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1) &>/dev/null

# Return v0.0.0 if no tags found
[ -z "$latest_release_tag" ] && latest_release_tag="v0.0.0"

# Set preliminary version
git_rev=${latest_release_tag#v}

# On push event
if [ "$GITHUB_EVENT_NAME" == "push" ]; then
    _sha=$GITHUB_SHA
    BRANCH_NAME=${GITHUB_REF##*/}
fi

# On pull_request event
if [ "$GITHUB_EVENT_NAME" == "pull_request" ]; then
    _sha=$(cat $GITHUB_EVENT_PATH | jq -r .pull_request.head.sha)
    BRANCH_NAME=${GITHUB_HEAD_REF}
fi

# If _sha is set, create Version var
[ -n "$_sha" ] && git_rev="${latest_release_tag}-${_sha:0:7}"

VERSION=${git_rev#v}

# On tag push that matches refs/tags/v*.*.*, use that version
if [[ $GITHUB_REF == refs/tags/v* ]]; then
    # Verify that version is semver; starts with refs/tags/v and ends at patch version
    echo $GITHUB_REF | egrep 'refs/tags/v[0-9]+\.[0-9]+\.[0-9]+$' && VERSION=${GITHUB_REF#*/v}
fi

[ -z "$VERSION" ] && exit 1
echo "Set version: ${VERSION}"

# Set GitHub Action environment and output variable
# VERSION
echo "::set-env name=VERSION::${VERSION}"
echo "::set-output name=VERSION::${VERSION}"

# COMMIT_SHA
echo "::set-env name=COMMIT_SHA::${_sha}"
echo "::set-output name=COMMIT_SHA::${_sha}"

# BRANCH_NAME
echo "::set-env name=BRANCH_NAME::${BRANCH_NAME}"
echo "::set-output name=BRANCH_NAME::${BRANCH_NAME}"

