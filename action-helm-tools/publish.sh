#!/bin/bash -l
set -eo pipefail

source $SCRIPT_DIR/common.sh
get_component_properties

export JFROG_CLI_OFFER_CONFIG=false

install_jfrog

if [[ -n "$PUBLISH_TO_REGISTRY" ]] && [[ "$PUBLISH_TO_REGISTRY" == "$GHCR_HELM_DEV_REGISTRY" ]]; then
  export HELM_EXPERIMENTAL_OCI=1

  echo "==> Publish to GHCR"

  echo "====> Saving chart $CHART_NAME:$VERSION"
	helm chart save $CHART_DIR $GHCR_HELM_DEV_REGISTRY/$CHART_NAME:$VERSION

  echo "====> Pushing chart $CHART_NAME:$VERSION to GHCR"
	helm chart push $GHCR_HELM_DEV_REGISTRY/$CHART_NAME:$VERSION
  echo "====> Chart $CHART_NAME:$VERSION pushed to GHCR"
else
  echo "==> Publish to Artifactory"
  echo "====> Check published version of $CHART_NAME"

  if jfrog rt s "$HELM_REPO/$CHART_NAME-$VERSION.tgz" --url $REGISTRY --apikey $ARTIFACTORY_PASSWORD --fail-no-op; then
      printf "$CHART_NAME-$VERSION already exist in artifactory $HELM_REPO, exit\n"
      exit 0
  else
      printf "==> Attempting to upload:\n$CHART_NAME-$VERSION.tgz to $HELM_REPO $REGISTRY\n\n"
      jfrog rt u $CHART_NAME-$VERSION.tgz $HELM_REPO --url $REGISTRY --apikey $ARTIFACTORY_PASSWORD --fail-no-op || exit 1
  fi
fi
