# github-workflow-dispatch.sh

Place the following snippet in your CircleCI config to call `package-helm` Github Actions workflow in your repository

```yaml
- run:
    name: Package Helm chart
    command: |
        ## VERSION_FILE is optional if version.txt is located in /workspace/version.txt
        # VERSION_FILE=/customPath/version.txt
        curl -s "https://raw.githubusercontent.com/qlik-oss/ci-tools/master/scripts-circleci/github-workflow-dispatch.sh" | bash
```
