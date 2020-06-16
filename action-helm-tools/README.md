# action-helm-tools

GitHub Action for packaging, testing helm charts and publishing to Artifactory helm repo

_Note this action is written to specifically work with Helm repos in Artifactory_

## Inputs

### Required
`action` - `[package, test, publish]`

- `package` - Involves helm client only and does dependency build, lint and package chart
- `test` - Creates K3d cluster, sets up helm, install chart in a namespace and waits for all pods to be up and running
- `publish` - Uses jfrog cli to check for existing package with same version and uploads if new chart is built
- `package_and_test` - Run `package` and `test` in one step


## Required Environment variables

```yaml
CHART_NAME: mycomponent # name of the chart
CHART_DIR: manifests/charts/mycomponent # chart path
REGISTRY: # Artifactory registry https://<company>.jfrog.io/<company>
HELM_PULL_REPO: # `helm repo add <name>` Artifactory helm chart repo name for pulling dependencies
HELM_PUSH_REPO: # Artifactory helm repository to push chart
HELM_REPO: # Artifactory virtual helm repo that holds dependencies
DOCKER_REGISTRY: xyz-docker.jfrog.io # Artifactory docker registry (as specified in chart image.registry)
DOCKER_REGISTRY_SECRET: xyz-docker-secret # Artifactory pull secret (as specified in chart image.pullSecrets)
DOCKER_EMAIL: xyx@tld.com # Docker email to use when creating k8s docker secret
ARTIFACTORY_USERNAME: ${{ secrets.ARTIFACTORY_USERNAME }} # ARTIFACTORY_USERNAME (Artifactory username) must be set in GitHub Repo secrets
ARTIFACTORY_PASSWORD: ${{ secrets.ARTIFACTORY_PASSWORD }} # ARTIFACTORY_PASSWORD (Artifactory api key) must be set in GitHub Repo secrets
```

## Optional Environment variables

```yaml
EXTRA_HELM_CMD: # Extra helm command(s) to use when installing chart in K3d cluster
HELM_VERSION: # Override helm version. Default "2.14.3"
KUBECTL_VERSION: # Override kubectl version. Default "1.15.4"
K3D_NAME: # Override K3D cluster name. Default "test"
K3S_VERSION: # Override K3s version. Default "v0.9.1"
K3D_WAIT: # Wait timeout for k3d cluster in seconds. Default 90
DEPLOY_TIMEOUT: # Timeout on waiting for pods to get to running state. Default 300 seconds
```


# Example workflow

```yaml
name: Helm lint, test, package and publish

on: pull_request

jobs:
  helm-suite:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2

    # - name: myOtherJob1
    #   run:

    - name: Package & Test Helm chart
      uses: ibiqlik/action-helm-tools@master
      with:
        action: "package_and_test"
      env:
        CHART_NAME: componentA
        CHART_DIR: manifests/charts/componentA
        HELM_PULL_REPO: myhelmrepo
        HELM_PUSH_REPO: helm
        REGISTRY: https://xyz.jfrog.io/xyz
        HELM_REPO: helmvirtual
        DOCKER_REGISTRY: xyz-docker.jfrog.io
        DOCKER_REGISTRY_SECRET: xyz-docker-secret
        DOCKER_EMAIL: xyx@tld.com
        ARTIFACTORY_USERNAME: ${{ secrets.ARTIFACTORY_USERNAME }}
        ARTIFACTORY_PASSWORD: ${{ secrets.ARTIFACTORY_PASSWORD }}
        EXTRA_HELM_CMD: "-f ./test/charts/values.yaml"

    - name: Publish Helm chart
      uses: ibiqlik/action-helm-tools@master
      with:
        action: "publish"
      env:
        CHART_NAME: componentA
        HELM_PUSH_REPO: helm
        REGISTRY: https://xyz.jfrog.io/xyz
        ARTIFACTORY_USERNAME: ${{ secrets.ARTIFACTORY_USERNAME }}
        ARTIFACTORY_PASSWORD: ${{ secrets.ARTIFACTORY_PASSWORD }}
```

---
TODO:
- Export pod logs if test(s) fail
