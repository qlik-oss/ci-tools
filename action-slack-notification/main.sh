#!/bin/bash -l
set -euo pipefail

echo "Repo: ${INPUT_REPOSITORY}"
echo "Webhook: ${INPUT_SLACK_WEBHOOK}"
url="$MASTER_NODE.pte.qlikdev.com"
msg="Cluster setup for $INPUT_REPOSITORY completed\nMaster node: $MASTER_NODE.qliktech.com\nKeycloak: https://keycloak.$url\nArgoCD: https://argocd.$url\nDocker registry: registry.$url\nTraefik dashboard: https://traefik.$url/dashboard/"
echo "Message: $msg"

# Try to read Slack channel from components.yaml
if [[ -f "${INPUT_REPOSITORY}/components.yaml" ]]; then
    channel=$(yq r ${INPUT_REPOSITORY}/components.yaml 'components[0].botSlackChannel')
    payload="{\"text\": \"$msg\", \"channel\": \"$channel\"}"
fi

# If channel is given as input, override the component.yaml setting
if [[ -n "$INPUT_CHANNEL" ]]; then
    channel=$INPUT_CHANNEL
    payload="{\"text\": \"$msg\", \"channel\": \"$channel\"}"
fi

# Fall back to  default Slack channel
if [[ -z $channel ]]; then
    payload="{\"text\": \"$msg\"}"
fi



curl --fail -H 'Content-Type: application/json' -d "$payload" $INPUT_SLACK_WEBHOOK
