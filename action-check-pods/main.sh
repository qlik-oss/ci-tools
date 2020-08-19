set -euo pipefail

SECONDS=0

while :
do
  # Check for pods that have containers which are not in the 'Ready' status
  POD_STATUS=$(kubectl get pods --no-headers --field-selector=status.phase!=Running,status.phase!=Succeeded)

  if  [[  -z "$POD_STATUS" ]]; then
    echo
    echo "INFO: All pods are Ready!"
    break
  elif [ $SECONDS -gt 1800 ]; then
    echo
    echo "ERROR: Some pods failed to enter the 'Running' or 'Completed' status!"
    echo "Pods not in 'Running' or 'Completed' status:"
    
    PODS=$(echo $POD_STATUS | awk '{print $1}')
    # Loop through each pod and display the events log for it
    while IFS= read -r PODS; do
      echo $PODS
      kubectl get events --field-selector involvedObject.name=$PODS
      kubectl logs --limit-bytes=0 --since=24h ${PODS}
      echo
    done <<< "$PODS"
    exit 1
  else
    echo "INFO: Pods still starting up. Retrying after sleep..."
    sleep 300
  fi
done

echo
echo "Checking if containers are ready..."

SECONDS=0
while :
do
  CONTAINER_STATUS=$(kubectl get pods -o json | jq -r '.items[] | select(.status.containerStatuses[].ready != true and .status.containerStatuses[].state.terminated.reason != "Completed") | .metadata.name' | uniq)

  if  [[  -z "$CONTAINER_STATUS" ]]; then
    echo
    echo "INFO: All containers are ready!"
    break
  elif [ $SECONDS -gt 1800 ]; then
    echo
    echo "ERROR: Some containers failed to enter the 'Ready' status!"
    echo "Pods with containers not in 'Ready' status:"
    echo "$CONTAINER_STATUS"
    exit 1
  else
    echo "INFO: Containers still starting up. Retrying after sleep..."
    sleep 300
  fi
done
