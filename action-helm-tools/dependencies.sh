#!/bin/bash -l
set -eo pipefail

source $SCRIPT_DIR/common.sh

helm_dependency_updater() {
  echo "==> Helm dependency update"
  # Get qlik dependencies
  deps=($(yq e '.dependencies[] | select(.repository == "@qlik") | .name + ";" + .version' $CHART_DIR/requirements.yaml))

  for dep in "${deps[@]}"; do
    IFS=";" read -r -a d <<< "${dep}"
      echo "Check for new version of ${d[0]}:${d[1]}"
      _latest=$(helm search repo "qlik/${d[0]}" -o yaml | yq e '.[0].version' -)
      if semver -r ">${d[1]}" $_latest; then
        echo "Update ${d[0]}:${d[1]} to $_latest"
        yq e -i '(.dependencies.[] | select(.name == "'"${d[0]}"'") | .version ) |= "'$_latest'"' "$CHART_DIR/requirements.yaml"
      else
        echo "${d[0]}:$_latest already up to date, continue"
      fi
  done

  helm dep update "$CHART_DIR"
}

commit_and_create_pullrequest() {
  BRANCH_NAME="ci-tools/helm-dependency-updater"
  COMMIT_MSG="chore(deps): Update helm requirements"

  git config --user.name "bot"
  git config --user.email "bot"
  git checkout "$BRANCH_NAME" 2>/dev/null || git checkout -b "$BRANCH_NAME"

  echo "Commit files to ${GITHUB_REPOSITORY} and create pull request"
  git add "$CHART_DIR/requirements.yaml" "$CHART_DIR/requirements.lock"

  if [ -n "$(git status --porcelain)" ]; then
    echo "Commit and push changes"
    git commit -m "$COMMIT_MSG"
    git push -u origin "$BRANCH_NAME"

    if ! gh pr list --repo "$GITHUB_REPOSITORY" | grep "$BRANCH_NAME"; then
      gh pr create --head "$BRANCH_NAME" --repo "$GITHUB_REPOSITORY" \
        --title "$COMMIT_MSG" \
        --body "$COMMIT_MSG"
    fi
  else
    echo "No changes to commit, DONE";
  fi
}

if [[ "${DEPENDENCY_UPDATE}" == "true" ]]; then
  sudo npm i -g semver
  get_component_properties
  add_helm_repos
  helm_dependency_updater
  commit_and_create_pullrequest
fi
