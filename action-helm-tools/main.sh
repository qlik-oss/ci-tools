#!/usr/bin/env bash
trap 'set_commit_status "error"' ERR

set -Eeo pipefail

export SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}" || realpath "${BASH_SOURCE[0]}")")

if [ -z "$VERSION" ]; then
    echo "ERROR: environment variable VERSION is not set"
    exit 1
fi

main() {

    if [[ -z "${INPUT_ACTION}" ]]; then
        "$SCRIPT_DIR/package.sh"
        "$SCRIPT_DIR/test.sh"
        "$SCRIPT_DIR/publish.sh"
    elif [[ "${INPUT_ACTION}" == "package_and_test" ]]; then
        "$SCRIPT_DIR/package.sh"
        "$SCRIPT_DIR/test.sh"
    else
        "$SCRIPT_DIR/$INPUT_ACTION.sh"
    fi

    "$SCRIPT_DIR/dependencies.sh"

}

set_commit_status() {
  STATUS=$1

  if [[ "$GITHUB_EVENT_NAME" == "workflow_dispatch" ]] && [[ -n "$GITHUB_SHA" ]] && [[ -n "$GITHUB_TOKEN" ]] && [[ -n "$GITHUB_REPOSITORY" ]]; then
    CONTEXT=${GITHUB_WORKFLOW:="Package Helm Chart"}
    GITHUB_API_URL=${GITHUB_API_URL:="https://api.github.com"}
    APIURL="${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/statuses/${GITHUB_SHA}"
    TARGET_URL="https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"

    curl --fail --silent "$APIURL" \
      -H "Content-Type: application/json" \
      -H "Authorization: token ${GITHUB_TOKEN}" \
      -X POST \
      -d "{\"state\": \"$STATUS\", \"context\": \"$CONTEXT\", \"target_url\": \"$TARGET_URL\"}"
  fi
}

set_commit_status "pending" # Indicate start of action on commit status
main
set_commit_status "success" # Indicate successful action run
