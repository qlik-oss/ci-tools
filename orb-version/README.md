## CircleCI orb

### Running orb in a workflow

In the following example, Github version info can be read from `workspace/version.txt` after the job `generate-version` completes. The `github/set-version` command accepts the parameters `path` and/or `file` if you want/need to override the path or name for the version text file.

```yaml
version: 2.1
description: This is a test job

orbs:
  github: qlikmats/github-version@0.0.14

jobs:
  generate-version:
    docker:
    - image: circleci/golang:1.15
    steps:
      - checkout
      - github/set-version

workflows:
  "Build my project":
    jobs:
      - generate-version
```
