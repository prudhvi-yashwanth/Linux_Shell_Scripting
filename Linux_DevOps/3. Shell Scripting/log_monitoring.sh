#!/bin/bash

##################################################
# Author: Prudhvi Yashwanth Reddy Kikkuru
# Date: 12th October 2025
# Description: Monitors log files modified in the last 24 hours.
#              Alerts DevOps team if error count exceeds threshold.
# Version: 1.0 (Base Version)
##################################################

set -euo pipefail
#set -x # Uncomment for debugging

# ==== Configuration ====
DATE=$(date +"%d-%b-%Y_%H:%M:%S")
LOG_DIR="/var/log/log-monitor"
LOG_FILE="$LOG_DIR/auto_log_monitor_$DATE.log"
ERROR_PATTERN=("ERROR" "CRITICAL" "FAILURE" "FATAL" "EXCEPTION")
ALERT_THRESHOLD=10
EMAIL_RECIPIENT="xxxxxx@gmail.com"

# === Ensure log directory exists ===
mkdir -p "$LOG_DIR"

echo -e "\n=== Log Files Monitoring Report ===" | tee -a "$LOG_FILE"
echo "Generated on: $(date)" | tee -a "$LOG_FILE"
echo "========================================================" | tee -a "$LOG_FILE"

log_files=$(find /var/log -type f -name "*.log" -mtime -1 -print 2>/dev/null || true)

if [ -z "$log_files" ]; then
    echo "No log files modified in the last 24 hours." | tee -a "$LOG_FILE"
    exit 0
fi

echo "Monitoring log files modified in the last 24 hours..." | tee -a "$LOG_FILE"
echo "$log_files" | tee -a "$LOG_FILE"

# === Function to check log files for error patterns ===
check_log_files() {
    for log_file in $log_files; do
        echo -e "\n===================================" | tee -a "$LOG_FILE"
        echo "Checking file: $log_file" | tee -a "$LOG_FILE"
        echo "===================================" | tee -a "$LOG_FILE"

        for pattern in "${ERROR_PATTERN[@]}"; do
            count=$(grep -ic "$pattern" "$log_file" || true)
            echo "Total '$pattern' occurrences in $log_file: $count" | tee -a "$LOG_FILE"

            if [ "$count" -ge "$ALERT_THRESHOLD" ]; then
                echo -e "\n⚠️ Alert: '$pattern' occurrences in $log_file have exceeded the threshold of $ALERT_THRESHOLD." | tee -a "$LOG_FILE"
                echo "Sending alert email to $EMAIL_RECIPIENT..." | tee -a "$LOG_FILE"
                mail -s "Log Alert: High '$pattern' in $log_file" "$EMAIL_RECIPIENT" <<< \
                    "The log file $log_file has $count occurrences of '$pattern', exceeding the threshold of $ALERT_THRESHOLD. Please investigate."
            else
                echo "✅ '$pattern' occurrences in $log_file are within acceptable range." | tee -a "$LOG_FILE"
            fi
        done
    done
}

# === Start Monitoring ===
check_log_files
echo -e "\n=== Log Monitoring Completed ===" | tee -a "$LOG_FILE"
echo "Report saved to $LOG_FILE"



# End of Script
# To make the script executable: chmod +x Auto_log_monitor.sh
# To run the script: sudo ./Auto_log_monitor.sh
# To schedule via cron, add the following line to crontab (runs daily at 2 AM):
# 0 2 * * * /path/to/Log_Files_Monitor/Auto_log_monitor.sh
# To sheduler via cron, to run for every 12 hours, add the following line to crontab:
# 0 */12 * * * /path/to/Log_Files_Monitor/Auto_log_monitor.sh