#!/bin/bash -l
set -eo pipefail

source $SCRIPT_DIR/common.sh

BRANCH_NAME="ci-tools/helm-dependency-updater"
COMMIT_MSG="chore(deps): Update helm requirements"

prep_git() {
  echo "==> Configure git, clean and reset to default branch"

  git config user.name github-actions
  git config user.email github-actions@github.com
  git fetch --prune --unshallow || true
  git fetch --all
  git checkout -- .
  DEFAULT_BRANCH=$(git ls-remote --symref "https://github.com/${GITHUB_REPOSITORY}.git" HEAD | grep refs/heads | awk '{split($2, a, "/"); print a[3] }')
  git checkout "$DEFAULT_BRANCH"
  git reset --hard "origin/$DEFAULT_BRANCH"

  # If branch already exists use that one otherwise create it
  git checkout "$BRANCH_NAME" 2>/dev/null || git checkout -b "$BRANCH_NAME"
}

helm_dependency_updater() {
  echo "==> Helm dependency update"

  # Get qlik dependencies
  deps=($(yq e '.dependencies[] | select(.repository == "@qlik") | .name + ";" + .version' $CHART_DIR/requirements.yaml))

  for dep in "${deps[@]}"; do
    IFS=";" read -r -a d <<< "${dep}"
      echo "Checking for new version of ${d[0]}:${d[1]}"
      echo "Latest version ${d[0]}:" # Next line prints out the version
      latest_chart_version=$(helm search repo "qlik/${d[0]}" -o yaml | yq e '.[0].version' -)
      if semver -r ">${d[1]}" $latest_chart_version; then
        echo "Update ${d[0]}:${d[1]} to $latest_chart_version"
        yq e -i '(.dependencies.[] | select(.name == "'"${d[0]}"'") | .version ) |= "'$latest_chart_version'"' "$CHART_DIR/requirements.yaml"
      else
        echo "${d[0]}:${d[1]} already up to date, continue"
      fi
  done

  helm dep update "$CHART_DIR"
}

commit_and_create_pullrequest() {
  echo "Commit files to ${GITHUB_REPOSITORY} and create pull request"
  git add "$CHART_DIR/requirements.yaml" "$CHART_DIR/requirements.lock"

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
