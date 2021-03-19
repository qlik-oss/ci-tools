# github-package-helm-dispatch.sh

Place the following snippet in your Jenkinsfile to call `package-helm` Github Actions workflow in your repository

And make sure that the environment variable **GH_ACCESS_TOKEN** is defined

**NOTE:** VERSION_FILE variable is optional if version.txt is located in `/workspace/version.txt`, if located elsewhere comment out the export command and set the correct path.

```Jenkinsfile
      // Package Helm chart
      sh 'export VERSION_FILE=./docker-version.txt ; curl -s "https://raw.githubusercontent.com/qlik-oss/ci-tools/master/scripts-circleci/github-package-helm-dispatch.sh" | bash'
```
