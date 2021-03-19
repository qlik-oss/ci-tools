# github-package-helm-dispatch.sh

Place the following snippet in your Jenkinsfile to call `package-helm` Github Actions workflow in your repository

And make sure that these environment variables are defined
* **GITHUB_OWNER** - typically `qlik-trial`
* **GITHUB_REPONAME** - repo name
* **GH_ACCESS_TOKEN** - token with repo scope

**NOTE:** VERSION_FILE variable is optional if version.txt is located in `/workspace/version.txt`, if located elsewhere comment out the export command and set the correct path.

```Jenkinsfile
      // Package Helm chart
      sh 'export VERSION_FILE=./docker-version.txt ; curl -s "https://raw.githubusercontent.com/qlik-oss/ci-tools/master/scripts-jenkins/github-package-helm-dispatch.sh" | bash'
```
