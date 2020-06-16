#!/bin/bash -l
set -o pipefail

# Get tags, latest release and its commit sha
git fetch --depth=1 origin +refs/tags/*:refs/tags/* || true

get_latest_tag="git tag -l --sort=-v:refname | egrep '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1"

if git tag -l 2> /dev/null; then
    LATEST_RELEASE=$(eval $get_latest_tag)
  else
    LATEST_RELEASE="v0.0.0"
fi

if [ "$GITHUB_EVENT_NAME" == "pull_request" ]; then
    GITHUB_SHA=$(cat $GITHUB_EVENT_PATH | jq -r .pull_request.head.sha)
    GIT_REV="${LATEST_RELEASE}-${GITHUB_SHA:0:7}"
    VERSION=${GIT_REV#v}
fi

# On tag push, set MAKE_RELEASE variable to true
if [ -n "${MAKE_RELEASE:-}" ]; then
    # Get version v*.*.* from GITHUB_REF="refs/tags/v1.2.3"
    VERSION=${GITHUB_REF#*/v}
fi

[ -z "$VERSION" ] && exit 1
export VERSION
echo "Set version: ${VERSION}"

# Set GitHub Action environment variable for following job steps
echo "::set-env name=VERSION::${VERSION}"
