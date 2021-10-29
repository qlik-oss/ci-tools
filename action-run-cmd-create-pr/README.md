# action-run-cmd-create-pr

A GitHub action for running a command to change a remote repository, make a commit and create a PR

## Example workflow

```yaml
- uses: actions/checkout@v2 # Optional (needed if script from source repo is used in command input)
- uses: qlik-oss/ci-tools/action-version@master # Optional (provided as an example action that sets VERSION variable)
- name: Update version
  uses: qlik-oss/ci-tools/action-run-cmd-create-pr@master
  with:
      gh_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
      owner: qlik-oss
      repository: ci-tools
      base_branch: # optional, if branch-off should not be done from default branch
      branch: update_version_to_${{ env.VERSION }}
      command: "command/script to run"
      commit_msg: "Changed version to ${{ env.VERSION }}"
      draft: true
      pre_approve: false
      approve_gh_token: ${{ secrets.GH_ACCESS_TOKEN_2 }}
      approve_user: bot2
      user: bot
      email: bot@example.com
```

In `command` input you can enter one line commands, for example:

`command: yq write --inplace someFile.yaml version 1.2.3`

or have a more elaborate script in the source repo and call it in the `command` input, for example:

`command: "source ${GITHUB_WORKSPACE}/.github/scripts/my-upd-script.sh"`

## Available tools

[see Dockerfile](/action-run-cmd-create-pr/Dockerfile)

If more tools are needed, either add them in Dockerfile or when using a script in `command` input add tools using `apk add myTool`
