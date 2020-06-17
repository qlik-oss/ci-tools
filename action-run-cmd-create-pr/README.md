# action-run-cmd-create-pr

A GitHub action for running a command to change a remote repository, make a commit and create a PR

## Example workflow

```yaml
- name: Update version
  uses: qlik-oss/ci-tools/action-run-cmd-create-pr@master
  with:
      gh_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
      group: qlik-oss
      repository: ci-tools
      branch: update_version_to_${{ env.LATEST_VERSION }}
      command: "command_to_run"
      commit_msg: "Changed version to ${{ env.LATEST_VERSION }}"
      draft: false
      user: bot
      email: bot@example.com
```
