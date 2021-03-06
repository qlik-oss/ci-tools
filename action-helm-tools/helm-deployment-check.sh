#!/bin/bash
set -eo pipefail

# Usage: ./helm_deployment_status.sh [--release qsefe] [--namespace default] [--timeout 300]

NAMESPACE=default
TIMEOUT=300

function process_args() {
    while (( "$#" ))
    do
        key="$1"
        case $key in
            -r|--release)
                export RELEASE="$2"
                shift
                ;;
            -n|--namespace)
                export NAMESPACE="$2"
                shift
                ;;
            -t|--timeout)
                export TIMEOUT="$2"
                shift
                ;;
        esac
            shift
    done
}

process_args "$@"

[[ -z "$RELEASE" ]] && echo "--release not provided" && exit 1

while [[ $SECONDS -lt $((SECONDS+60)) ]]; do
  if helm get manifest $RELEASE --namespace $RELEASE; then
    break
  fi
done

get_pods() {
  pods=$(kubectl get pods -n $NAMESPACE -o json | jq -r '.items[] | select(.status.phase? != "Running" or .status.containerStatuses[]?.ready != true) | .metadata.name' )
  echo "Pods not ready: $pods"
}

get_pods

echo "==> checking pods"
deployed=0
_timeout=$((SECONDS+$TIMEOUT))
while [[ $SECONDS -lt $_timeout ]]; do
  if [[ -z "$pods" ]]; then
    echo "All deployments are OK"
    deployed=1
    break
  else
    get_pods
    sleep 10
  fi
done

POD_LOGS="${GITHUB_WORKSPACE}/podlogs/" && mkdir -p "${POD_LOGS}"
echo "POD_LOGS=${POD_LOGS}" >> $GITHUB_ENV

if [[ $deployed -ne 1 ]]; then
  echo "==> ERROR"
  echo "$RELEASE deployment failed, pods not started are: "
  echo "$pods"
  kubectl get pods --all-namespaces
  echo "==> Get logs"
  for pod in $pods; do
    set +e
    logfile="${POD_LOGS}/${pod}.log"
    echo "==> Pod logs: $pod" | tee -a "$logfile"
    kubectl logs -n "$NAMESPACE" "$pod" --all-containers 2>&1 | tee -a "$logfile"
    echo "==> Pod describe: $pod" | tee -a "$logfile"
    kubectl describe pod -n "$NAMESPACE" "$pod" 2>&1 | tee -a "$logfile"
  done
  exit 1
fi

echo "==> Pods"
kubectl get pods -n $NAMESPACE
