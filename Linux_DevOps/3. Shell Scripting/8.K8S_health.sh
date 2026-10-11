#!/bin/bash

set -euo pipefail

# -----------------------------------
# Check Kubernetes Cluster Access
# -----------------------------------
check_cluster_access() {

    if ! kubectl cluster-info > /dev/null 2>&1; then
        echo "ERROR: Unable to access Kubernetes cluster"
        exit 1
    fi
}

# -----------------------------------
# Check Pod Health
# -----------------------------------
check_pod_health() {

    unhealthy_found=false

    echo "Checking pod health..."
    echo "---------------------------------------------"

    kubectl get pods -A --no-headers | while read -r namespace pod ready status rest
    do

        if [[ "$status" != "Running" && "$status" != "Completed" ]]; then

            unhealthy_found=true

            echo "Namespace : $namespace"
            echo "Pod       : $pod"
            echo "Status    : $status"
            echo "---------------------------------------------"

        fi

    done

    if [[ "$unhealthy_found" == false ]]; then
        echo "All pods are healthy"
    fi
}

# -----------------------------------
# Main Function
# -----------------------------------
main() {

    check_cluster_access

    check_pod_health
}

main
