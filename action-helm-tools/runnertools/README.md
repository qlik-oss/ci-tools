# GitHub self-hosted runner image for K8s operations

This docker image is used in self-hosted runners in isolation (to not contaminate the runner)

```
jobs:
  k8s:
    runs-on: self-hosted
    container:
      image: ilirbekteshi/runnertools:latest
      volumes:
        - /local_path_on_runner/.kube:/.kube
    steps:
    - uses: actions/checkout@v2

    - name: Set ENV
      run: echo "::set-env name=KUBECONFIG::/.kube/config"

    - name: Some K8s script to deploy
      timeout-minutes: 20
      run: ./scripts/deploy.sh
```
