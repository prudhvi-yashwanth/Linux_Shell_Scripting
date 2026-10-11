#!/bin/bash

set -euo pipefail

LOG_FILE="/var/log/nginx/access.log"
TEMP_FILE="/tmp/last_one_hour.log"
OUTPUT_FILE="/tmp/nginx_log_report.txt"
TOP_COUNT=5

# -----------------------------
# Check log file exists
# -----------------------------
check_log_file() {

    if [[ ! -f "$LOG_FILE" ]]; then
        echo "ERROR: Log file not found: $LOG_FILE"
        exit 1
    fi

    if [[ ! -r "$LOG_FILE" ]]; then
        echo "ERROR: Log file is not readable"
        exit 1
    fi

    if [[ ! -s "$LOG_FILE" ]]; then
        echo "WARN: Log file is empty!.Please check log file at $LOG_FILE"
        exit 1
    fi


}

# -----------------------------
# Extract last 1 hour logs
# -----------------------------
extract_last_one_hour_logs() {

    current_hour=$(date '+%d/%b/%Y:%H')

    previous_hour=$(date -d "1 hour ago" '+%d/%b/%Y:%H')

    grep -E "$current_hour|$previous_hour" "$LOG_FILE" > "$TEMP_FILE"
}

# -----------------------------
# Process logs
# -----------------------------
process_logs() {

    total_requests=$(wc -l < "$TEMP_FILE")

    if [[ "$total_requests" -eq 0 ]]; then
        echo "No logs found for last 1 hour"
        exit 0
    fi

    echo "Top $TOP_COUNT IPs generating 4xx/5xx errors"
    echo "--------------------------------------------------"

    awk '

    $9 ~ /^[45][0-9][0-9]$/ {
        errors[$1]++
    }

    END {
        for (ip in errors) {
            print ip, errors[ip]
        }
    }

    ' "$TEMP_FILE" | sort -k2 -nr | head -n "$TOP_COUNT" | while read -r ip count
    do

        # percentage=$(awk -v c="$count" -v t="$total_requests" \
        # 'BEGIN { printf "%.2f", (c/t)*100 }')
        percentage=$(echo "scale=2; ($count/$total_requests)*100" | bc)
        echo ""
        echo "IP Address : $ip" 
        echo "Errors     : $count"
        echo "Percentage : $percentage%" 
        echo "-------------------------------------------"

    done 
}
# -----------------------------
# Cleanup
# -----------------------------
cleanup() {
    rm -f "$TEMP_FILE"
}
# -----------------------------
# Main Function
# -----------------------------
main() {
    check_log_file
    extract_last_one_hour_logs
    process_logs
    cleanup
} > "$OUTPUT_FILE" 2>&1 

main
