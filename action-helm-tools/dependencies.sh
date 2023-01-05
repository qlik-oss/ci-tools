#!/bin/bash -l
set -eo pipefail

source $SCRIPT_DIR/common.sh

BRANCH_NAME="ci-tools/helm-dependency-updater"
COMMIT_MSG="chore(deps): Update helm requirements"

REGISTRY=https://ghcr.io
TAGS_FILE=docker.register.tags
TOKEN=`echo $GITHUB_TOKEN | base64`
WGET_COMMAND="wget -O- -q -S"

listTags() {
  image=$1
  TAGS_LINK="/v2/qlik-prod/helm/${image}/tags/list?n=100"
  while true; do
   ${WGET_COMMAND} --header="Authorization: Bearer ${TOKEN}" "${REGISTRY}${TAGS_LINK}" 2>${TAGS_FILE} | jq -r ".tags | .[]" 
   TAGS_LINK=`grep Link ${TAGS_FILE} 2>/dev/null | cut -d\< -f2 | cut -d\> -f1`
   if [ ! -n "${TAGS_LINK}" ] ; then break; fi
  done
}

prep_git() {
  echo "==> Configure git, clean and reset to default branch"

  git config user.name github-actions
  git config user.email github-actions@github.com
  git fetch --prune --unshallow || true
  git fetch --all
  git checkout -f -- .
  DEFAULT_BRANCH=$(git ls-remote --symref "https://github.com/${GITHUB_REPOSITORY}.git" HEAD | grep refs/heads | awk '{split($2, a, "/"); print a[3] }')
  git checkout "$DEFAULT_BRANCH"
  git reset --hard "origin/$DEFAULT_BRANCH"

  # If branch already exists use that one otherwise create it
  git checkout "$BRANCH_NAME" 2>/dev/null || git checkout -b "$BRANCH_NAME"
}

helm_dependency_updater() {
  echo "==> Helm dependency update"

  export DEPENDENCIES_FILE
  export DEPENDENCIES_LOCK_FILE
  if [[ "$CHART_APIVERSION" = "v1" ]]; then
    DEPENDENCIES_FILE="$CHART_DIR/requirements.yaml"
    DEPENDENCIES_LOCK_FILE="$CHART_DIR/requirements.lock"
    if [ ! -f "$CHART_DIR/requirements.yaml" ]; then
      echo "No requirements found, continue."
      exit 0
    fi
  elif [[ "$CHART_APIVERSION" = "v2" ]]; then
    DEPENDENCIES_FILE="$CHART_DIR/Chart.yaml"
    DEPENDENCIES_LOCK_FILE="$CHART_DIR/Chart.lock"
  else
    echo "::warning ::Could not determine helm apiVersion from $CHART_DIR/Chart.yaml"
    exit 0
  fi

  UPDATE_AVAILABLE=0

  deps=($(yq e '.dependencies[] | select(.repository == "oci://ghcr.io/qlik-trial/helm") | .name + ";" + .version' $DEPENDENCIES_FILE))

  [ ${#deps[@]} -eq 0 ] && exit 0

  for dep in "${deps[@]}"; do
    IFS=";" read -r -a d <<< "${dep}"
      echo "Checking for new version of ${d[0]}:${d[1]}"
      latest_chart_version=$(listTags ${d[0]} | sort -V | tail -n 1)
      echo "Latest available version ${d[0]}:$latest_chart_version"
      if semver -r ">${d[1]}" $latest_chart_version; then
        echo "Update ${d[0]}:${d[1]} to $latest_chart_version"
        yq e -i '(.dependencies.[] | select(.name == "'"${d[0]}"'") | .version ) |= "'$latest_chart_version'"' "$DEPENDENCIES_FILE"
        UPDATE_AVAILABLE=1
      else
        echo "${d[0]}:${d[1]} already up to date, continue"
      fi
  done

  if [ "$UPDATE_AVAILABLE" -eq "1" ]; then
    helm version
    helm repo list
    echo "RUNNING helm dep update"
    helm dep update "$CHART_DIR"
    echo "FINISHED Running helm dep update"
  else
    echo "No updates available, continue"
    exit 0
  fi
}

commit_and_create_pullrequest() {
  echo "Commit files to ${GITHUB_REPOSITORY} and create pull request"
  git add "$DEPENDENCIES_FILE" "$DEPENDENCIES_LOCK_FILE"

  if [ -n "$(git status --porcelain)" ]; then # If there are staged changes
    echo "Commit and push changes"
    git commit -m "$COMMIT_MSG"
    git push -u origin "$BRANCH_NAME"

    if ! gh pr list --repo "$GITHUB_REPOSITORY" | grep "$BRANCH_NAME"; then # Check in case there is an existing PR
      gh pr create --head "$BRANCH_NAME" --repo "$GITHUB_REPOSITORY" --title "$COMMIT_MSG" --body "$COMMIT_MSG"
    fi
  else
    echo "No changes to commit, DONE";
  fi
}

if [[ "${DEPENDENCY_UPDATE}" == "true" ]]; then
  if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "GITHUB_TOKEN missing, cannot update dependencies"
    exit 0
  fi
  prep_git
  sudo npm i -g semver
  get_component_properties
  add_helm_repos
  helm_dependency_updater
  commit_and_create_pullrequest
fi
