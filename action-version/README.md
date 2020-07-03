# action-version

Sets output and environment variable that can be used in subsequent GitHub Action steps in the same Job.

## Outputs

### VERSION

- `1.2.3-<short-commit-sha>` - Returns a version based on latest tag matching exactly `v*.*.*` suffixed with short commit ID
- `0.0.0-<short-commit-sha>` - When no tags available returns version `0.0.0`
- `1.2.3` - If a tag `v*.*.*` is pushed (a release) it returns the same tag

*`v` (version) prefix is omitted in all cases*

**Note: `1.2.3-<short-commit-sha>` is only returned on `push` and `pull_request` GitHub events/triggers. On other types of triggers, it will return the latest release tag `1.2.3`**

### COMMIT_SHA

This variable always returns the commit sha ID on `push` and `pull_request` events.

GitHub Actions does not reliably set commit sha ID on the same environment variable or in the event information.

For example on Pull request the commit can only be found on the `GITHUB_EVENT_PATH` json file under `pull_request.head.sha`, while on `push` it is available in env var `GITHUB_SHA`.

_`GITHUB_SHA` in pull_request refers to the pull request object ID not the commit._

### BRANCH_NAME

Returns only branch name on `push` and `pull_request` events

### RELEASE_TAG

Return `1` if workflow is triggered using:

```yaml
on:
  push:
    tags:
      - 'v*.*.*'
```

Otherwise, return `0`

## Use in GitHub Actions - workflow

```yaml
...
jobs:
  somejob:
    steps:
      - uses: actions/checkout@v2
      - name: Get Version
        id: version
        uses: qlik-oss/ci-tools/action-version@master
```

If only environment variable is used, the action can be called using oneline only

```yaml
jobs:
  somejob:
    steps:
      - uses: actions/checkout@v2
      - uses: qlik-oss/ci-tools/action-version@master
```

Example on how to use the variable (otherwise not needed in workflow)

```yaml
...
      - name: Print version
        run: |
          # Version will be available as output and environment variable
          echo "From output ${{ steps.version.outputs.version }}"
          echo "From env $VERSION"
...
```
