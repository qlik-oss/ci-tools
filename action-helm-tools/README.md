# action-helm-tools

GitHub Action for packaging, testing helm charts and publishing to Artifactory helm repo

_Note this action is written to specifically work with Helm repos in Artifactory_

## Inputs

### Required
`action` - `[package, test, publish]`

- `package` - Involves helm client only and does dependency build, lint and package chart
- `test` - Creates K8s cluster (in Docker), sets up helm, install chart in a namespace and waits for all pods to be up and running
- `publish` - Uses jfrog cli to check for existing package with same version and uploads if new chart is built
- `package_and_test` - Run `package` and `test` in one step

## Version

`VERSION` set as environment variable is required

### Use action-version to set VERSION variable

```yaml
steps:
  - uses: actions/checkout@v2
  - uses: qlik-oss/ci-tools/action-version@master
```

## Required Environment variables

```yaml
CHART_NAME: mycomponent # name of the chart
CHART_DIR: manifests/charts/mycomponent # chart path
REGISTRY: # Artifactory registry URL https://<company>.jfrog.io/<company>
HELM_REPO: # Artifactory helm repository to push chart to
HELM_LOCAL_REPO: # `helm repo add <name>` Artifactory helm chart repo name for pulling dependencies
HELM_VIRTUAL_REPO: # Artifactory virtual helm repo that holds dependencies
K8S_DOCKER_REGISTRY: xyz-docker.jfrog.io # Artifactory docker registry (as specified in chart image.registry)
K8S_DOCKER_REGISTRY_SECRET: xyz-docker-secret # Artifactory pull secret (as specified in chart image.pullSecrets)
K8S_DOCKER_EMAIL: xyx@tld.com # Docker email to use when creating k8s docker secret
ARTIFACTORY_USERNAME: ${{ secrets.ARTIFACTORY_USERNAME }} # ARTIFACTORY_USERNAME (Artifactory username) must be set in GitHub Repo secrets
ARTIFACTORY_PASSWORD: ${{ secrets.ARTIFACTORY_PASSWORD }} # ARTIFACTORY_PASSWORD (Artifactory api key) must be set in GitHub Repo secrets
```

## Optional Environment variables

```yaml
EXTRA_HELM_CMD: # Extra helm command(s) to use when installing chart in K8s cluster
HELM_VERSION: # Override helm version. Default "2.14.3"
KUBECTL_VERSION: # Override kubectl version. Default "1.15.4"
KIND_VERSION: Override KIND version. Default version - look in common.sh
KIND_IMAGE: Override KIND image (K8s version). Default version - look in common.sh
DEPLOY_TIMEOUT: # Timeout on waiting for pods to get to running state. Default 300 seconds
```

## Example workflow

```yaml
name: Helm lint, test, package and publish

on: pull_request

jobs:
  helm-suite:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: qlik-oss/ci-tools/action-version@master

    # - name: myOtherJob1
    #   run:

    - name: Package & Test Helm chart
      uses: qlik-oss/ci-tools/action-helm-tools@master
      with:
        action: "package_and_test"
      env:
        CHART_NAME: componentA
        CHART_DIR: manifests/charts/componentA
        HELM_LOCAL_REPO: myhelmrepo
        HELM_REPO: helm
        REGISTRY: https://xyz.jfrog.io/xyz
        HELM_VIRTUAL_REPO: helmvirtual
        K8S_DOCKER_REGISTRY: xyz-docker.jfrog.io
        K8S_DOCKER_REGISTRY_SECRET: xyz-docker-secret
        K8S_DOCKER_EMAIL: xyx@tld.com
        ARTIFACTORY_USERNAME: ${{ secrets.ARTIFACTORY_USERNAME }}
        ARTIFACTORY_PASSWORD: ${{ secrets.ARTIFACTORY_PASSWORD }}
        EXTRA_HELM_CMD: "-f ./test/charts/values.yaml"

    - name: Publish Helm chart
      uses: qlik-oss/ci-tools/action-helm-tools@master
      with:
        action: "publish"
      env:
        CHART_NAME: componentA
        HELM_REPO: helm
        REGISTRY: https://xyz.jfrog.io/xyz
        ARTIFACTORY_USERNAME: ${{ secrets.ARTIFACTORY_USERNAME }}
        ARTIFACTORY_PASSWORD: ${{ secrets.ARTIFACTORY_PASSWORD }}
```

Or set Env var globally

```yaml
name: Helm lint, test, package and publish

on: pull_request

env:
  CHART_NAME: componentA
  CHART_DIR: manifests/charts/componentA
  HELM_LOCAL_REPO: myhelmrepo
  HELM_REPO: helm
  REGISTRY: https://xyz.jfrog.io/xyz
  HELM_VIRTUAL_REPO: helmvirtual
  K8S_DOCKER_REGISTRY: xyz-docker.jfrog.io
  K8S_DOCKER_REGISTRY_SECRET: xyz-docker-secret
  K8S_DOCKER_EMAIL: xyx@tld.com
  ARTIFACTORY_USERNAME: ${{ secrets.ARTIFACTORY_USERNAME }}
  ARTIFACTORY_PASSWORD: ${{ secrets.ARTIFACTORY_PASSWORD }}
  EXTRA_HELM_CMD: "-f ./test/charts/values.yaml"

jobs:
  helm-suite:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: qlik-oss/ci-tools/action-version@master

    # - name: myOtherJob1
    #   run:

    - name: Package & Test Helm chart
      uses: qlik-oss/ci-tools/action-helm-tools@master
      with:
        action: "package_and_test"

    - name: Publish Helm chart
      uses: qlik-oss/ci-tools/action-helm-tools@master
      with:
        action: "publish"
```

---
TODO:

- Export pod logs if test(s) fail
