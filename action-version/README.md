# action-version

Sets output and environment variable that can be used in subsequent GitHub Action steps in the same Job.

*`v` (version) prefix is omitted in all cases*

- `1.2.3-<short-commit-sha>` - Returns a version based on latest tag matching exactly `v*.*.*` suffixed with short commit ID
- `0.0.0-<short-commit-sha>` - When no tags available returns version `0.0.0`
- `1.2.3` - If a tag `v*.*.*` is pushed (a release) it returns the same tag


## Use in GitHub Actions - workflow

```yaml
...
jobs:
  somejob:
    steps:
      - name: Get Version
        id: version
        uses: qlik-oss/ci-tools/action-version@master
```

If only environment variable is used, the action can be called using oneline only

```yaml
jobs:
  somejob:
    steps:
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