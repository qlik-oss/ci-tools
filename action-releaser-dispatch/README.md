# action-releaser-dispatch

Make GitHub dispatch call with `pre-release` event to trigger release process.

The action will only trigger if the required environment variable `VERSION` is semantic version `vX.Y.Z`, if not then it will continue without error.

## Required environment variables

- `GH_PAT` - GitHub Personal Access Token
- `VERSION` - Component version to release

## Optional environment variables

- `BRANCH_TO_RELEASE_FROM` - Branch to release from in component repository; if this variable is not set, the default branch will be used as branch to release from

### If used in full Github action workflow

- `- uses: qlik-oss/ci-tools/action-version@master` - This actions automatically set required Version variable as required by this action
- Workflow is triggered on tag `v*.*.*` push

## Use in GitHub Actions - workflow

```yaml
on:
  push:
    tags:
      - 'v*.*.*'
  pull_request:
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
