#!/bin/bash
set -euo pipefail

# -----------------------------------
# Config
# -----------------------------------
SERVICES=("httpd" "nginx" "mysql" "postgresql" "docker")
LOG_FILE="/var/log/service_health_monitor.log"

# Ensure log file is writable
touch "$LOG_FILE" 2>/dev/null || { echo "Cannot write to $LOG_FILE. Run with sudo?"; exit 1; }

# -----------------------------------
# Helpers
# -----------------------------------
timestamp() {
  date "+%d-%m-%Y %H:%M:%S"
}

log() {
  local message="$1"
  echo "$(timestamp) : $message" >> "$LOG_FILE"
}

# -----------------------------------
# Check if service exists
# -----------------------------------
check_service_exists() {
  local service="$1"
  if ! systemctl list-unit-files | grep -q "^${service}.service"; then
    log "ERROR: Service does not exist: $service"
    return 1
  fi
}

# -----------------------------------
# Restart service
# -----------------------------------
restart_service() {
  local service="$1"
  log "Attempting to restart $service..."
  if systemctl restart "$service"; then
    sleep 2
    if systemctl is-active --quiet "$service"; then
      log "Service $service restarted successfully"
      return 0
    else
      log "CRITICAL: Service $service restart failed"
      return 1
    fi
  else
    log "ERROR: Failed to issue restart command for $service"
    return 1
  fi
}

# -----------------------------------
# Check service status
# -----------------------------------
check_service_status() {
  local service="$1"
  log "Checking status for $service"

  if ! check_service_exists "$service"; then
    return 1
  fi

  if systemctl is-active --quiet "$service"; then
    log "Service $service is running"
    return 0
  else
    log "Service $service is DOWN"
    restart_service "$service"
  fi
}

# -----------------------------------
# Main
# -----------------------------------
main() {
  local failures=0

  for svc in "${SERVICES[@]}"; do
    if ! check_service_status "$svc"; then
      failures=$((failures + 1))
    fi
  done

  if [[ "$failures" -gt 0 ]]; then
    log "Service health check completed with $failures failure(s)"
    exit 1
  else
    log "Service health check completed successfully"
    exit 0
  fi
}

main
