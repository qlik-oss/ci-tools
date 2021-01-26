# action-repository-dispatch

Make GitHub repository dispatch call.

## Required environment variables

- `GITHUB_TOKEN` - GitHub Personal Access Token

## Use in GitHub Actions - workflow

```yaml
jobs:
  somejob:
    steps:
      - uses: qlik-oss/ci-tools/action-repository-dispatch@master
        env:
          GITHUB_TOKEN: ${{ secrets.GH_ACCESS_TOKEN }}
        with:
          owner: gitOwner
          repository: gitRepo
          event_type: myEvent
          client_payload: '{"input1":"value2","input2":"value2"}'
```
