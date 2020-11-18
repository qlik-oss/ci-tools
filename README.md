# CI/Build Tools

Place each action/tool/script in their own folder named after their purpose. If applicable add a README.md with usage instructions of the tool.

Prefix GitHub Actions with `action-`


## GitHub Actions

### Checkout this repo in a workflow

```yaml
...
jobs:
  myJob:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
      with:
        repository: qlik-oss/ci-tools
        path: ci-tools
        ref: branch/tag/SHA (default master)

    - run: ./ci-tools/path/to/scripts
```

### Running GitHub actions in a workflow

```yaml
...
jobs:
  myJob:
    runs-on: ubuntu-latest
    steps:
    - name: myActions
      uses: qlik-oss/ci-tools/action-myAction@master
```

## Notes

Add executable permissions to scripts so that they are runnable after checkout `git update-index --chmod=+x script.sh`
