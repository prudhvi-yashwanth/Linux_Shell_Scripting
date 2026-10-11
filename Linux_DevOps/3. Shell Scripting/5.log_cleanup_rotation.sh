#!/bin/bash
set -euo pipefail

# -----------------------------------
# Config
# -----------------------------------
LOG_DIR="/var/log/myapps"
ARCHIVE_DIR="${LOG_DIR}/archive"
RETENTION_DAYS=7
LOG_EXTENSION="log"
TIMESTAMP=$(date '+%d-%m-%Y_%H-%M-%S')

# -----------------------------------
# Validate Log Directory
# -----------------------------------
validate_log_directory() {
    [[ -d "$LOG_DIR" ]] || exit 0
}

# -----------------------------------
# Create Archive Directory
# -----------------------------------
create_archive_directory() {
    mkdir -p "$ARCHIVE_DIR"
}

# -----------------------------------
# Archive Single Log File
# -----------------------------------
archive_log_file() {
    local file="$1"
    [[ -f "$file" ]] || return 0

    local basename
    basename=$(basename "$file")

    mv "$file" "${ARCHIVE_DIR}/${basename}_${TIMESTAMP}"
    gzip "${ARCHIVE_DIR}/${basename}_${TIMESTAMP}"
    echo "Archived: ${basename} -> ${ARCHIVE_DIR}/${basename}_${TIMESTAMP}.gz"
}

# -----------------------------------
# Cleanup Old Archives
# -----------------------------------
cleanup_old_archives() {
    find "$ARCHIVE_DIR" -type f -name "*.gz" -mtime +"$RETENTION_DAYS" -delete
    echo "Cleaned up archives older than $RETENTION_DAYS days"
}

# -----------------------------------
# Main Function
# -----------------------------------
main() {
    validate_log_directory
    create_archive_directory

    for logfile in "$LOG_DIR"/*.${LOG_EXTENSION}; do
        archive_log_file "$logfile"
    done

    cleanup_old_archives
    exit 0
}

main
