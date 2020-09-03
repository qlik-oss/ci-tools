# action-check-pods

A GitHub action for checking if pods and containers are up and running in a namespace

## Example workflow

```yaml
...
- name: A step that deploys to kubernetes
...
- name: Check pods
  uses: qlik-oss/ci-tools/action-check-pods@master
  with:
      namespace: test-namespace
