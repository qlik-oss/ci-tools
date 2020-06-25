# action-releaser-dispatch

Make GitHub dispatch call with `pre-release` event to trigger release process

## Use in GitHub Actions - workflow

Call on GitHub trigger

```yaml
on:
  push:
    tags:
      -'v*.*.*'
```

**Requires `- uses: qlik-oss/ci-tools/action-version@master`**

```yaml
on:
  push:
    tags:
      - 'v*.*.*'
[...]
jobs:
  somejob:
    steps:
      - uses: actions/checkout@v2
      - uses: qlik-oss/ci-tools/action-version@master
      - uses: qlik-oss/ci-tools/action-releaser-dispatch@master
```
