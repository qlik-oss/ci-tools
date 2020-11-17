# github-package-helm-dispatch.sh

Place the following snippet in your CircleCI config to call `package-helm` Github Actions workflow in your repository

**NOTE:** VERSION_FILE variable is optional if version.txt is located in `/workspace/version.txt`, if located elsewhere comment out the export command and set the correct path.

```yaml
- run:
    name: Package Helm chart
    command: |
        # export VERSION_FILE=/customPath/version.txt
        curl -s "https://raw.githubusercontent.com/qlik-oss/ci-tools/master/scripts-circleci/github-package-helm-dispatch.sh" | bash
```
