# action-check-pods

A GitHub action for checking if pods and containers are up and running in a namespace

## Example workflow

```yaml
- uses: actions/checkout@v2 # Optional (needed if script from source repo is used in command input)
- uses: qlik-oss/ci-tools/action-version@master # Optional (provided as an example action that sets VERSION variable)
- name: Check pods
  uses: qlik-oss/ci-tools/action-check-pods@master
  with:
      namespace: test-namespace
```
