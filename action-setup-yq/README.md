# action-setup-yq

Installs and adds `yq` to PATH ready to use

## INPUTS

`version` - [optional] YQ version to install, default: `3.3.2`

## Use in GitHub Actions - workflow

```yaml
...
jobs:
  somejob:
    steps:
      - uses: qlik-oss/ci-tools/action-setup-yq@master
```

With version:

```yaml
...
jobs:
  somejob:
    steps:
      - uses: qlik-oss/ci-tools/action-setup-yq@master
        with:
          version: 3.3.1
```
