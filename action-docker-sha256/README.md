# action-docker-sha256

Sets output and environment variable that can be used in subsequent GitHub Action steps in the same Job.

## Outputs

### DOCKER_SHA256

Returns docker sha256 for given image 

```yaml
on:
  push:
    tags:
      - 'v*.*.*'
```

## Use in GitHub Actions - workflow

```yaml
...
jobs:
  somejob:
    steps:
      - uses: actions/checkout@v2
      - name: Calculate docker sha256
        id: docker-sha256
        uses: qlik-oss/ci-tools/action-docker-sha256@master
```

If only environment variable is used, the action can be called using oneline only

```yaml
jobs:
  somejob:
    steps:
      - uses: actions/checkout@v2
      - uses: qlik-oss/ci-tools/action-docker-sha256@master
```

Example on how to use the variable (otherwise not needed in workflow)

```yaml
...
      - name: Print SHA
        run: |
          # Version will be available as output and environment variable
          echo "From output ${{ steps.docker-sha256.outputs.docker-sha256 }}"
          echo "From env $DOCKER_SHA256"
...
```
