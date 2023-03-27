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
  pods=$(kubectl get pods -n $NAMESPACE -o json)
}

# An ok_pod is a pod whose deployment is OK. More exactly, an ok_pod is a pod for which the following conditions are true:
#
# A. status.phase == "Running"
# B. status.containerStatuses.ready == true
#
# A nok_pod is a pod whose deployment is not OK, i.e. a pod for which condition A and/or B is not true.
#
# Note: A pod could change from being an ok_pod to being a nok_pod. In other words, pod state could degrade. For example,
# during startup of a kubernetes cluster, a pod's status.phase value could change from "Running" to "CrashLoopBackOff".
get_nok_pods() {
  get_pods
  nok_pods=$(echo $pods | jq -r '.items[] | select(.status.phase? != "Running" or .status.containerStatuses[]?.ready != true) | .metadata.name' )
  echo "Pods which are not OK: $nok_pods"
}

get_nok_pods

echo "==> checking pods"
deployed=0
_timeout=$((SECONDS+$TIMEOUT))
while [[ $SECONDS -lt $_timeout ]]; do
  if [[ -z "$nok_pods" ]]; then
    echo "All pods are OK"
    deployed=1
    break
  else
    sleep 10
    get_nok_pods
  fi
done

if [[ $deployed == 1 ]]; then
  sleep 5
  get_nok_pods
  if [[ -n "$nok_pods" ]]; then
    echo "==> DEGRADATION"
    # For info about CrashLoopBackOff, see https://sysdig.com/blog/debug-kubernetes-crashloopbackoff
    echo "Some pod has degraded from 'OK' to 'not OK', possibly because the status phase for the pod changed from 'Running' to 'CrashLoopBackOff'"
    deployed=0
  fi
fi

POD_LOGS="${GITHUB_WORKSPACE}/podlogs/" && mkdir -p "${POD_LOGS}"
echo "POD_LOGS=${POD_LOGS}" >> $GITHUB_ENV

kubectl get pods --all-namespaces

echo "==> Get logs"
for pod in $pods; do
  set +e
  logfile="${POD_LOGS}/${pod}.log"
  echo "==> Pod logs (current instances): $pod" | tee -a "$logfile"
  kubectl logs -n "$NAMESPACE" "$pod" --all-containers 2>&1 | tee -a "$logfile"
  echo "==> Pod logs (previous instances): $pod" | tee -a "$logfile"
  kubectl logs -n "$NAMESPACE" "$pod" -p --all-containers 2>&1 | tee -a "$logfile"
  echo "==> Pod describe: $pod" | tee -a "$logfile"
  kubectl describe pod -n "$NAMESPACE" "$pod" 2>&1 | tee -a "$logfile"
done

if [[ $deployed -ne 1 ]]; then
  echo "==> ERROR"
  echo "$RELEASE deployment failed; the following pods are not OK (have status.phase != 'Running' or status.containerStatuses.ready != true):"
  echo "$nok_pods"
  exit 1
fi

echo "==> Pods"
kubectl get pods -n $NAMESPACE
