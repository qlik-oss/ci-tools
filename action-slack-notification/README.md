# action-check-pods

A GitHub action for posting a Slack message upon dev cluster creation completion

## Example workflow

```yaml
    ...
    - uses: actions/checkout@v2
    with:
        repository: qlik-trial/${{ github.event.inputs.repository }}
        path: ${{ github.event.inputs.repository }}
        token: ${{ secrets.GH_ACCESS_TOKEN }}

    - name: Slack notification
    uses: qlik-oss/ci-tools/action-slack-notification@master
    with:
        webhook: ${{ secrets.SLACK_WEBHOOK }}
        repository: ${{ github.event.inputs.repository }}
```

**Note** The environment variable `MASTER_NODE` needs to be defined.