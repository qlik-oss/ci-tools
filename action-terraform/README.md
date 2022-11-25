# action-terraform

Run terraform commands: version, init, fmt, lint, validate, plan, apply.

## Use in GitHub Actions - workflow

### Single command
```yaml
...
jobs:
  somejob:
    steps:
      - uses: actions/checkout@v3
      - name: Terraform fmt
        uses: qlik-oss/ci-tools/action-terraform@master
        with:
          commands: "fmt"
```

### Multiple commands
```yaml
...
jobs:
  somejob:
    steps:
      - uses: actions/checkout@v3
      - name: Terraform fmt
        uses: qlik-oss/ci-tools/action-terraform@master
        with:
          commands: "lint, validate, plan, apply"
```

### Specify terraform dir and version
```yaml
...
jobs:
  somejob:
    steps:
      - uses: actions/checkout@v3
      - name: Terraform fmt
        uses: qlik-oss/ci-tools/action-terraform@master
        with:
          commands: "apply"
          chdir: "terraform"
          terraform_version: "1.3.5"
```
