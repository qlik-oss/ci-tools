# action-print-event-info

GitHub Action for printing event info.

# Example workflow

```yaml
on: workflow_dispatch

jobs:
  print-event-info:
    runs-on: ubuntu-latest
    steps:
      - uses: qlik-oss/ci-tools/action-print-event-info@master
  hello-world:
    runs-on: ubuntu-latest
    steps:
      - name: Hello world
        run: |
          echo "Hello world!"
```
