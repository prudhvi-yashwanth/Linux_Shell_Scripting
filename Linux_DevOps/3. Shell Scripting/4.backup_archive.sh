#!/bin/bash
set -euo pipefail

# -----------------------------------
# Config
# -----------------------------------
SOURCE_DIR="/opt/app"
BACKUP_DIR="/backup"
ARCHIVE_DIR="${BACKUP_DIR}/archive"
RETENTION_DAYS=7

TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
BACKUP_FILE="backup_${TIMESTAMP}.tar.gz"

# -----------------------------------
# Validate Source Directory
# -----------------------------------
validate_source() {
    if [[ ! -d "$SOURCE_DIR" ]]; then
        echo "ERROR: Source directory does not exist"
        exit 1
    fi
}

# -----------------------------------
# Create Backup Directory
# -----------------------------------
create_backup_directory() {
    mkdir -p "$BACKUP_DIR" "$ARCHIVE_DIR"
}

# -----------------------------------
# Create Backup
# -----------------------------------
create_backup() {
    echo "Creating backup..."
    tar -czf "${BACKUP_DIR}/${BACKUP_FILE}" "$SOURCE_DIR"
    echo "Backup created successfully"
    echo "Backup File: ${BACKUP_DIR}/${BACKUP_FILE}"
}

# -----------------------------------
# Archive Backup
# -----------------------------------
archive_backup() {
    echo "Archiving backup..."
    mv "${BACKUP_DIR}/${BACKUP_FILE}" "${ARCHIVE_DIR}/"
    echo "Backup archived to ${ARCHIVE_DIR}/${BACKUP_FILE}"
}

# -----------------------------------
# Cleanup Old Backups
# -----------------------------------
cleanup_old_backups() {
    echo "Removing backups older than $RETENTION_DAYS days..."
    find "$ARCHIVE_DIR" -name "*.tar.gz" -mtime +"$RETENTION_DAYS" -delete
    echo "Old backup cleanup completed"
}

# -----------------------------------
# Main Function
# -----------------------------------
main() {
    validate_source
    create_backup_directory
    create_backup
    archive_backup
    cleanup_old_backups
}

main
