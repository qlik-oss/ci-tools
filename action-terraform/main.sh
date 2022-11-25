#!/bin/bash

terraform_init() {
  terraform -chdir=$INPUTS_CHDIR init -backend=true 
}

terraform_fmt() {
  terraform -chdir=$INPUTS_CHDIR fmt
}

terraform_lint() {
  terraform -chdir=$INPUTS_CHDIR fmt -check -diff -no-color
}

terraform_validate() {
  terraform -chdir=$INPUTS_CHDIR init -backend=false
	terraform -chdir=$INPUTS_CHDIR validate
}

terraform_plan() {
  terrraform -chdir=$INPUTS_CHDIR plan
}

terraform_apply() {
  terraform -chdir=$INPUTS_CHDIR apply -auto-approve=true
}

for command in $(echo $INPUTS_COMMANDS| tr ',' ' '); do
  case $command in
    init)
      terraform_init
      ;;
    fmt)
      terraform_fmt
      ;;
    lint)
      terraform_lint
      ;;
    validate)
      terraform_validate
      ;;
    plan)
      terraform_plan
      ;;
    apply)
      terraform_apply
      ;;
    *)
      echo "Error: Unknown terraform command!"
      exit 2
      ;;
  esac
done
