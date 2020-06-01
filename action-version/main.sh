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
[ "$GITHUB_EVENT_NAME" == "push" ] && _sha=$GITHUB_SHA

# On pull_request event
[ "$GITHUB_EVENT_NAME" == "pull_request" ] && _sha=$(cat $GITHUB_EVENT_PATH | jq -r .pull_request.head.sha)

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
echo "::set-env name=VERSION::${VERSION}"
echo "::set-output name=VERSION::${VERSION}"
