#!/bin/bash

set -euo pipefail
THRESHOLD=80
LOG_FILE="/var/log/disk_usage_monitor.log"
FILESYSTEM=("/var" "/" "/home" "/boot" "/usr" "/bin" "/opt")


# -----------------------------------
# Creating the log file & TimeStamp
# -----------------------------------
touch "$LOG_FILE" 2>/dev/null || { echo "Cannot write to $LOG_FILE. Run with sudo?"; exit 1; }
calculate_timestamp() {
  date "+%d-%m-%Y %H:%M:%S"
}


# -----------------------------------
# Writing into log file
# -----------------------------------
log() {
  local message="$1"
  printf "%s : %s\n" "$(calculate_timestamp)" "$message" >> "$LOG_FILE"
}


# -----------------------------------
# Check disk usage
# -----------------------------------
get_disk_usage() {
  local MOUNT_POINT="$1"
  local usage 

  if ! df -P "$MOUNT_POINT" > /dev/null 2>&1; then
    log "ERROR: Mount point $MOUNT_POINT not found"
    return 1 
  fi 

  usage=$(df -P "$MOUNT_POINT" | tail -1 | awk '{print $5}' | tr -d '%')

  if (( usage >= THRESHOLD )); then
    log "WARNING!! Disk usage on $MOUNT_POINT exceed threshold ${THRESHOLD}% (Current: ${usage}%)"
    return 1 
  else 
    log "Disk usage on $MOUNT_POINT is within safe limits (${usage}%)"
    return 0 
  fi 
} 



# -----------------------------------
# Main Function
# -----------------------------------
main() {
  EXIT_CODE=0
  for FS in "${FILESYSTEM[@]}"; do 
    if ! get_disk_usage "$FS"; then
      EXIT_CODE=1
    fi 
  done 
  exit $EXIT_CODE
}

main
