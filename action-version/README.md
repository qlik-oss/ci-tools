# action-version

Sets output and environment variable that can be used in subsequent GitHub Action steps in the same Job.

## Outputs

### VERSION

Returns version based on `git describe --tags --abbrev=7`, see https://git-scm.com/docs/git-describe for more details

- `1.2.3-n-g<short-commit-sha>` - Most recent tag - number of commits since tag - short commit sha preffixed with g
- `0.0.0-0-g<short-commit-sha>` - When no tags are available it returns version `0.0.0-0` and short commit sha
- `1.2.3` - If a tag `v*.*.*` is pushed (a release tag), it will return the same tag without describing git repository

*`v` (version) prefix is omitted in all cases*

### COMMIT_SHA

This variable always returns the commit sha ID on `push` and `pull_request` events.

GitHub Actions does not reliably set commit sha ID on the same environment variable or in the event information.

For example on Pull request the commit can only be found on the `GITHUB_EVENT_PATH` json file under `pull_request.head.sha`, while on `push` it is available in env var `GITHUB_SHA`.

_`GITHUB_SHA` in pull_request refers to the pull request object ID not the commit._

### BRANCH_NAME

Returns only branch name on `push` and `pull_request` events. If used on tag push then BRANCH_NAME is returned empty

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
