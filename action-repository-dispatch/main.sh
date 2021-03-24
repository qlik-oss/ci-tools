#!/bin/bash -l
set -euo pipefail

if [ -z "$GITHUB_TOKEN" ]; then
  echo "GITHUB_TOKEN not available"
  exit 1
fi

# INPUT_EVENT_TYPE
# INPUT_CLIENT_PAYLOAD

body_template='{"event_type":"%s","client_payload":%s}'
body=$(printf $body_template "$INPUT_EVENT_TYPE" "$INPUT_CLIENT_PAYLOAD")
echo "Using ${body}"

curl -i --fail --location --request POST "${GITHUB_API_URL}/repos/${INPUT_OWNER}/${INPUT_REPOSITORY}/dispatches" \
  --header "Authorization: token ${GITHUB_TOKEN}" \
  --header "Content-Type: application/json" \
  --header "Accept: application/vnd.github.v3+json" \
  --data "${body}"
