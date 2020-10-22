# action-setup-gomplate

Installs and adds `gomplate` to PATH ready to use

## INPUTS

`gomplate_version` - [optional] gomplate version to install, default: `3.8.0`

## Use in GitHub Actions - workflow

```yaml
...
jobs:
  somejob:
    steps:
      - uses: qlik-oss/ci-tools/action-setup-gomplate@master
```

With specific version:

```yaml
...
jobs:
  somejob:
    steps:
      - uses: qlik-oss/ci-tools/action-setup-gomplate@master
        with:
          gomplate_version: 3.7.0
```
