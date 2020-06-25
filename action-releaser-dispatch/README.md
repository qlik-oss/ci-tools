# action-releaser-dispatch

Make GitHub dispatch call with `pre-release` event to trigger release process

## Requires

- `- uses: qlik-oss/ci-tools/action-version@master` - Version
- `GH_PAT` GitHub Personal Access Token
- Workflow that is triggered on tag `v*.*.*` push

## Use in GitHub Actions - workflow

```yaml
on:
  push:
    tags:
      - 'v*.*.*'
[...]
jobs:
  somejob:
    steps:
      - uses: actions/checkout@v2
      - uses: qlik-oss/ci-tools/action-version@master
      - uses: qlik-oss/ci-tools/action-releaser-dispatch@master
        env:
          GH_PAT: ${{ secrets.GH_PAT }}
```
