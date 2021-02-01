# action-repository-dispatch

Make GitHub repository dispatch call.

## Required environment variables

- `GITHUB_TOKEN` - GitHub Personal Access Token

## Use in GitHub Actions - workflow

```yaml
jobs:
  somejob:
    steps:
      - name: Create payload using variables
        run: |
          payload=$(jq -cn --arg EnvVar "$EnvVar" '{"myKey":$EnvVar}')
          echo "payload=$payload" >> $GITHUB_ENV

      - uses: qlik-oss/ci-tools/action-repository-dispatch@master
        env:
          GITHUB_TOKEN: ${{ secrets.GH_ACCESS_TOKEN }}
        with:
          owner: gitOwner
          repository: gitRepo
          event_type: myEvent
          client_payload: '{"input1":"value2","input2":"value2"}'
          # OR use input from create payload using variables job
          client_payload: ${{ env.payload }}
```
