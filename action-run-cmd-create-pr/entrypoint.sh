#!/bin/bash

# A script which clones a github repository, runs a command assumed to change the code in
# the cloned repository, commits and uploads the change and finally creates a pull request
# for the change.

echo "--- Environment variables used by entrypoint.sh ---"
echo "INPUT_GH_TOKEN: ************"
echo "INPUT_GROUP: ${INPUT_GROUP}"
echo "INPUT_REPOSITORY: ${INPUT_REPOSITORY}"
echo "INPUT_BRANCH: ${INPUT_BRANCH}"
echo "INPUT_COMMAND: ${INPUT_COMMAND}"
echo "INPUT_COMMIT_MSG: ${INPUT_COMMIT_MSG}"
echo "INPUT_DRAFT: ${INPUT_DRAFT}"
echo "INPUT_USER: ${INPUT_USER}"
echo "INPUT_EMAIL: ${INPUT_EMAIL}"
echo "INPUT_LABEL: ${INPUT_LABEL}"
echo "---------------------------------------------------"

# Clone repository and run command
git clone https://${INPUT_GH_TOKEN}@github.com/${INPUT_GROUP}/${INPUT_REPOSITORY}.git
cd ${INPUT_REPOSITORY}
git config user.email "${INPUT_EMAIL}"
git config user.name "${INPUT_USER}"

# Create a local branch. If a remote branch with the same name exists, set up the local branch to track the remote branch.
git branch -r --contains origin/${INPUT_BRANCH} > /dev/null 2>&1
if [[ $? -ne 0 ]]
then
  git checkout -b ${INPUT_BRANCH}
else
  git branch ${INPUT_BRANCH} origin/${INPUT_BRANCH}
  git checkout ${INPUT_BRANCH}
fi

eval "${INPUT_COMMAND}"
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "COMMAND failed with exit code $retVal. Exiting."
  exit 1
elif [ -z "$(git diff-index HEAD)" ]; then
  echo "COMMAND did not change the status of the repository. Exiting."
  exit 1
else
  # Commit and upload change
  git commit -a -m "${INPUT_COMMIT_MSG}"
  git push origin ${INPUT_BRANCH}

  # Set pull request information
  API_VERSION=v3
  BASE=https://api.github.com
  AUTH_HEADER="Authorization: token ${INPUT_GH_TOKEN}"
  HEADER="Accept: application/vnd.github.${API_VERSION}+json"
  HEADER="${HEADER}; application/vnd.github.antiope-preview+json; application/vnd.github.shadow-cat-preview+json"
  REPO_URL="${BASE}/repos/${INPUT_GROUP}/${INPUT_REPOSITORY}"
  PULLS_URL=${REPO_URL}/pulls
  TARGET="master"
  SOURCE="${INPUT_BRANCH}"
  BODY="---"
  DATA="{\"title\":\"${INPUT_COMMIT_MSG}\", \"body\":\"${BODY}\", \"base\":\"${TARGET}\", \"head\":\"${SOURCE}\", \"draft\":${INPUT_DRAFT}}"

  # Create pull request
  ISSUE_NUMBER=$(curl -sSL -H "${AUTH_HEADER}" -H "${HEADER}" --user "${INPUT_USER}" -X POST --data "${DATA}" ${PULLS_URL} | jq -r '.number')

  REGEX_IS_NUMBER='^[0-9]+$'
  if ! [[ $ISSUE_NUMBER =~ $REGEX_IS_NUMBER ]] ; then
    echo "Could not create pull request. Exiting." >&2; exit 1
  fi

  echo "Pull request #${ISSUE_NUMBER} created successfully"

  if [ -z ${INPUT_LABEL+x} ]; then
    echo "No label set. Exiting."
  else
    echo "Updating pull request to include label ${INPUT_LABEL}"

    UPDATE_DATA="{\"labels\":[\"${INPUT_LABEL}\"]}"
    UPDATE_PULLS_URL=${REPO_URL}/issues/${ISSUE_NUMBER}/labels

    # Update PR to include a label
    curl -sSL -H "${AUTH_HEADER}" -H "${HEADER}" --user "${INPUT_USER}" -X POST --data "${UPDATE_DATA}" ${UPDATE_PULLS_URL}
  fi
fi