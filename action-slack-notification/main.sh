#!/bin/bash -l
set -euo pipefail

echo "Repo: ${INPUT_REPOSITORY}"
echo "Webhook: ${INPUT_SLACK_WEBHOOK}"

cat ${INPUT_REPOSITORY}/components.yaml

url="$MASTER_NODE.pte.qlikdev.com"
msg="Cluster setup for $INPUT_REPOSITORY completed\nMaster node: $MASTER_NODE.qliktech.com\nKeycloak: https://keycloak.$url\nArgoCD: https://argocd.$url\nDocker registry: registry.$url\nTraefik dashboard: https://traefik.$url/dashboard/"
echo "Message: $msg"

curl --fail -H 'Content-Type: application/json' -d "{\"text\": \"$msg\", \"channel\": \"@mats.jacobsson\"}" $INPUT_SLACK_WEBHOOK
