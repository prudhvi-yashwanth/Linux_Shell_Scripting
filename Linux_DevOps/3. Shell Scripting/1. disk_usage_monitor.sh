#!/bin/bash
#
# disk_usage_monitor.sh
# Monitors disk usage for a list of critical filesystems/directories.
# Logs a WARNING when usage crosses WARN_LIMIT, and a CRITICAL alert
# when usage crosses CRIT_LIMIT. Exits non-zero if any filesystem is
# in CRITICAL state, so it can be hooked into cron/alerting pipelines.
#
# Usage: ./disk_usage_monitor.sh
# Recommended cron (every 15 min for prod-critical systems):
#   */15 * * * * /opt/scripts/disk_usage_monitor.sh

set -euo pipefail

# ---------- Configuration ----------
WARN_LIMIT=80
CRIT_LIMIT=90
LIST_OF_FILES=('/' '/home' '/var/log' '/tmp')
LOG_FILE='/var/log/disk_usage.log'

# ---------- Setup ----------
# Ensure log file exists (and its directory is writable)
if [[ ! -f "$LOG_FILE" ]]; then
    touch "$LOG_FILE" 2>/dev/null || {
        echo "ERROR: Cannot create log file at $LOG_FILE" >&2
        exit 1
    }
fi

# Reusable timestamped logger
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Track whether any filesystem hit CRITICAL, to set final exit code
CRITICAL_FOUND=0

# ---------- Core check ----------
get_disk_usage() {
    local FILE="$1"
    local USAGE
    USAGE=$(df -P "$FILE" | tail -1 | awk '{print $5}' | tr -d '%')

    if [[ "$USAGE" -ge "$CRIT_LIMIT" ]]; then
        log "CRITICAL: $FILE is at ${USAGE}% usage (threshold: ${CRIT_LIMIT}%)"
        CRITICAL_FOUND=1
    elif [[ "$USAGE" -ge "$WARN_LIMIT" ]]; then
        log "WARNING: $FILE is at ${USAGE}% usage (threshold: ${WARN_LIMIT}%)"
    else
        log "OK: $FILE is at ${USAGE}% usage"
    fi
}

# ---------- Driver ----------
check_disk_usage() {
    for FILE in "${LIST_OF_FILES[@]}"; do
        if [[ -e "$FILE" && -r "$FILE" ]]; then
            get_disk_usage "$FILE"
        else
            log "ERROR: $FILE does not exist or is not readable."
        fi
    done
}

check_disk_usage

if [[ "$CRITICAL_FOUND" -eq 1 ]]; then
    exit 2   # non-zero exit so cron/CI/alerting can detect critical state
fi

exit 0