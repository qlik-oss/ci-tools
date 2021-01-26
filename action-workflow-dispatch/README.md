# action-workflow-dispatch

Make GitHub workflow dispatch call.

## Required environment variables

- `GITHUB_TOKEN` - GitHub Personal Access Token

## Use in GitHub Actions - workflow

```yaml
jobs:
  somejob:
    steps:
      - uses: qlik-oss/ci-tools/action-workflow-dispatch@master
        env:
          GITHUB_TOKEN: ${{ secrets.GH_ACCESS_TOKEN }}
        with:
          owner: gitowner
          repository: gitrepo
          ref: # optional
          workflow: myDispatchWF.yaml
          inputs: '{"input1":"value2","input2":"value2"}'
```
