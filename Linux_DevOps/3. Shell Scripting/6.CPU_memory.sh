#!/bin/bash

set -euo pipefail

CPU_THRESHOLD=80
MEMORY_THRESHOLD=75

# -----------------------------------
# Validate Thresholds
# -----------------------------------
validate_thresholds() {

    if ! [[ "$CPU_THRESHOLD" =~ ^[0-9]+$ ]]; then
        echo "ERROR: CPU threshold must be numeric"
        exit 1
    fi

    if ! [[ "$MEMORY_THRESHOLD" =~ ^[0-9]+$ ]]; then
        echo "ERROR: Memory threshold must be numeric"
        exit 1
    fi
}

# -----------------------------------
# Check CPU Usage
# -----------------------------------
check_cpu_usage() {

    cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d'.' -f1)

    cpu_usage=$((100 - cpu_idle))

    echo "CPU Usage: ${cpu_usage}%"

    if [[ "$cpu_usage" -ge "$CPU_THRESHOLD" ]]; then
        echo "ALERT: CPU usage exceeded threshold"
    fi
}

# -----------------------------------
# Check Memory Usage
# -----------------------------------
check_memory_usage() {

    memory_usage=$(free | awk '/Mem/ {printf("%.0f"), $3/$2 * 100}')

    echo "Memory Usage: ${memory_usage}%"

    if [[ "$memory_usage" -ge "$MEMORY_THRESHOLD" ]]; then
        echo "ALERT: Memory usage exceeded threshold"
    fi
}

# -----------------------------------
# Main Function
# -----------------------------------
main() {

    validate_thresholds

    check_cpu_usage

    check_memory_usage
}

main
