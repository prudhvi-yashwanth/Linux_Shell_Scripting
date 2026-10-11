#!/bin/bash
set -euo pipefail

# -----------------------------------
# Config
# -----------------------------------
LOG_DIR="/var/log/myapp"
OUTPUT_FAIL="/var/log/error_report.log"
PATTERNS=("ERROR" "WARNING" "FATAL" "CRITICAL" "CAUTION" "INFO" "DANGER")

# -----------------------------------
# Helpers
# -----------------------------------
timestamp() {
  date '+%d-%m-%Y %H:%M:%S'
}

log() {
  local message="$1"
  echo "$(timestamp): $message" >> "$OUTPUT_FAIL"
}

# -----------------------------------
# Process one log file
# -----------------------------------
process_log_file() {
  local file="$1"
  local found=0

  for pattern in "${PATTERNS[@]}"; do
    if grep -q "$pattern" "$file"; then
      log "Found $pattern in $file"
      grep "$pattern" "$file" >> "$OUTPUT_FAIL"
      found=1
    fi
  done

  return $found
}

# -----------------------------------
# Main
# -----------------------------------
main() {
  local errors_found=0

  # Ensure output file exists
  touch "$OUTPUT_FAIL" 2>/dev/null || { echo "Cannot write to $OUTPUT_FAIL. Run with sudo?"; exit 1; }

  # Loop through all .log files in directory
  for logfile in "$LOG_DIR"/*.log; do
    [[ -f "$logfile" ]] || continue

    if ! process_log_file "$logfile"; then
      errors_found=1
    fi
  done

  # Final status
  if (( errors_found == 1 )); then
    log "Log monitoring completed: ERROR FOUND"
    exit 1
  else
    log "Log monitoring completed: no error found"
    exit 0
  fi
}

main


# cron usage example
# */10 * * * * /home/ubuntu/scripts/log_error_monitor.sh >> /var/log/cron_log_monitor.log 2>&1
