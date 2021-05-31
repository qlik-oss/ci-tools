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

`.github/workflows/package-helm.yaml`

``` yaml
name: Package Helm chart
on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Version used in Docker image tag and Helm chart'
        required: true
      commitsha:
        description: 'Commit SHA'
        required: false

env:
  VERSION: ${{ github.event.inputs.version }}
  COMMITSHA: ${{ github.event.inputs.commitsha }}
  # Constants
  PUBLISH_TO_REGISTRY: ${{ secrets.GHCR_HELM_DEV_REGISTRY }}
  GHCR_DOCKER_DEV_REGISTRY: ${{ secrets.GHCR_DOCKER_DEV_REGISTRY }}
  GHCR_DOCKER_DEV_USERNAME: ${{ secrets.GHCR_DOCKER_DEV_USERNAME }}
  GHCR_DOCKER_DEV_PASSWORD: ${{ secrets.GHCR_DOCKER_DEV_PASSWORD }}
  GHCR_HELM_DEV_REGISTRY: ${{ secrets.GHCR_HELM_DEV_REGISTRY }}
  GHCR_HELM_DEV_USERNAME: ${{ secrets.GHCR_HELM_DEV_USERNAME }}
  GHCR_HELM_DEV_PASSWORD: ${{ secrets.GHCR_HELM_DEV_PASSWORD }}
jobs:
  package-chart:
    name: Package Helm chart
    runs-on: ubuntu-latest
    steps:
      # Prints Action envrionment information useful for debugging
      - uses: qlik-oss/ci-tools/action-print-event-info@master

      - uses: actions/checkout@v2
        with:
          ref: ${{ github.event.inputs.commitsha }}

      # This step will package and publish helm chart but also do various testing, for example
      # Yaml lint, helm lint; create isolated k8s cluster using KIND, deploy chart
      # and test that all pods are up and running
      - name: Helm package and test
        uses: qlik-oss/ci-tools/action-helm-tools@master
        env:
          GITHUB_TOKEN:

      # This step will trigger Qlik Release only when semver (vX.Y.Z) tag is pushed to repo
      # https://github.com/qlik-oss/ci-tools/tree/master/action-releaser-dispatch
      - name: Qlik Releaser
        uses: qlik-oss/ci-tools/action-releaser-dispatch@master
        env:
          GITHUB_TOKEN:
```
