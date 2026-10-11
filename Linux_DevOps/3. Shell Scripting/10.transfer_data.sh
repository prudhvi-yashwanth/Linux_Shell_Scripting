#!/bin/bash

set -euo pipefail

# -----------------------------------
# Variables
# -----------------------------------

SOURCE_PATH="/data/"
DEST_USER="ubuntu"
DEST_HOST="192.168.1.100" # sample host IP
DEST_PATH="/backup/data"
SSH_KEY="/home/user/.ssh/id_rsa"
LOG_FILE="/var/log/rsync_transfer.log"

# -----------------------------------
# Validate Source
# -----------------------------------

validate_source() {

    if [[ ! -d "$SOURCE_PATH" ]]; then
        echo "ERROR: Source path does not exist"
        exit 1
    fi
}

# -----------------------------------
# Check SSH Connectivity
# -----------------------------------

check_ssh_connection() {

    ssh -i "$SSH_KEY" \
    -o BatchMode=yes \
    -o ConnectTimeout=10 \
    "${DEST_USER}@${DEST_HOST}" exit

    echo "SSH connectivity successful"
}

# -----------------------------------
# Transfer Files
# -----------------------------------

transfer_files() {
    echo "Starting secure file transfer..."

    rsync -avzP --delete \
    -e "ssh -i $SSH_KEY" \
    "$SOURCE_PATH" \
    "${DEST_USER}@${DEST_HOST}:${DEST_PATH}" \
    >> "$LOG_FILE" 2>&1

    echo "File transfer completed successfully"
}

# -----------------------------------
# Main Function
# -----------------------------------
main() {
    validate_source
    check_ssh_connection
    transfer_files
}
main
