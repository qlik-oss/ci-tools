# update-chart-dependency.sh

Get the file in GitHub actions

```yaml
    - name: Get update chart dependency script
    working-directory: .ciscripts
    run: |
      SCRIPT=update-chart-dependency.sh
      wget "https://raw.githubusercontent.com/qlik-oss/ci-tools/master/scripts/${SCRIPT}"
      chmod +x "$SCRIPT"
      # bash update-chart-dependency.sh # Optional if the script is used in another step
```

Execute script on a different repo and create a pull request

```yaml
    - name: Update chart dependency
      uses: qlik-oss/ci-tools/action-run-cmd-create-pr@master
      with:
        gh_token: ${{ secrets.GH_PAT }}
        owner: # github owner
        repository: # git repository
        branch: depupd/${{ env.CHART_NAME }}_${{ env.VERSION }}
        command: "source .ciscripts/update-chart-dependency.sh"
        commit_msg: "chore(deps) integration of ${{ env.CHART_NAME }} ${{ env.VERSION }}"
        draft: false
        user: bot # user to associate commit with
        email: # email to associate commit with
```
