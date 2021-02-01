#!/bin/bash -l
set -xeuo pipefail

if [ -z "$GITHUB_TOKEN" ]; then
  echo "GITHUB_TOKEN not available"
  exit 1
fi

if [ -z "$INPUT_REF" ]; then
  INPUT_REF=$(gh api "repos/${INPUT_OWNER}/${INPUT_REPOSITORY}" | jq -r .default_branch)
fi

body_template='{"ref":"%s","inputs":%s}'
body=$(printf $body_template "$INPUT_REF" "$INPUT_INPUTS")
echo "Using ${body}"

URL="${GITHUB_API_URL}/repos/${INPUT_OWNER}/${INPUT_REPOSITORY}/actions/workflows/${INPUT_WORKFLOW}/dispatches"

curl --fail --location --request POST "$URL" \
  --header "Authorization: token ${GITHUB_TOKEN}" \
  --header "Content-Type: application/json" \
  --header "Accept: application/vnd.github.v3+json" \
  --data "${body}"
