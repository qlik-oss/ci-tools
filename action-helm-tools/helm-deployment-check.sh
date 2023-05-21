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
  pods=$(kubectl get pods -n $NAMESPACE -o json | jq -r '.items[] | .metadata.name' )
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
  nok_pods=$(kubectl get pods -n precog-web-source-kinds -o json | jq -r '.items[] | select((.status.phase? != "Running" or .status.containerStatuses[]?.ready != true) and (.status.phase? != "Succeeded")) | .metadata.name')
}

get_nok_pods

echo "==> Check pods in namespace $NAMESPACE"
deployed=0
_timeout=$((SECONDS+$TIMEOUT))
while [[ $SECONDS -lt $_timeout ]]; do
  if [[ -z "$nok_pods" ]]; then
    echo "All pods in namespace $NAMESPACE are OK"
    deployed=1
    break
  else
    echo "The following pods in namespace $NAMESPACE are not OK:"
    echo "$nok_pods"
    sleep 10
    get_nok_pods
  fi
done

if [[ $deployed == 1 ]]; then
  sleep 5
  get_nok_pods
  if [[ -n "$nok_pods" ]]; then
    echo "==> DEGRADATION"
    # Example of pod degradation: status.phase changes from "Running" to "CrashLoopBackoff"
    # For info about CrashLoopBackOff, see https://sysdig.com/blog/debug-kubernetes-crashloopbackoff
    echo "The following pods in namespace $NAMESPACE have degraded (changed state from 'OK' to 'not OK'):"
    echo "$nok_pods"
    deployed=0
  fi
fi

POD_LOGS_DIR="${GITHUB_WORKSPACE}/podlogs/" && mkdir -p "${POD_LOGS_DIR}"
echo "POD_LOGS_DIR=${POD_LOGS_DIR}" >> $GITHUB_ENV

echo "==> Print pod info for all namespaces"
kubectl get pods --all-namespaces

echo "==> Get logs for pods in namespace $NAMESPACE"
get_pods
for pod in $pods; do
  set +e
  logfile="${POD_LOGS_DIR}/${pod}.log"
  echo "==> 'kubectl logs' for pod $pod (current container instances):" | tee -a "$logfile"
  kubectl logs -n "$NAMESPACE" "$pod" --all-containers 2>&1 | tee -a "$logfile"
  echo "==> 'kubectl logs' for pod $pod (previous container instances):" | tee -a "$logfile"
  kubectl logs -n "$NAMESPACE" "$pod" -p --all-containers 2>&1 | tee -a "$logfile"
  echo "==> 'kubectl describe' for pod $pod:" | tee -a "$logfile"
  kubectl describe pod -n "$NAMESPACE" "$pod" 2>&1 | tee -a "$logfile"
done

if [[ $deployed -ne 1 ]]; then
  echo "==> ERROR"
  echo "$RELEASE deployment failed; the following pods in namespace $NAMESPACE are not OK (have status.phase != 'Running' or status.containerStatuses.ready != true):"
  echo "$nok_pods"
  exit 1
fi

echo "==> Print pod info for namespace $NAMESPACE"
kubectl get pods -n $NAMESPACE
