# action-releaser-dispatch

Make GitHub dispatch call with `release` event to trigger release process.

The action will only trigger if the required environment variable `VERSION` is semantic version `vX.Y.Z`, if not then it will continue without error.

## Required environment variables

- `GITHUB_TOKEN` - GitHub Personal Access Token
- `VERSION` - Component version to release

## Optional environment variables

- `BRANCH_TO_RELEASE_FROM` - Branch to release from in component repository; defaults to empty string, causing the release to be done from the default branch

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
          GITHUB_TOKEN: ${{ secrets.GH_ACCESS_TOKEN }}
```
