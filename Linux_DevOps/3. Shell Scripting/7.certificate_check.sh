#!/bin/bash

set -euo pipefail

DOMAIN="${1:-}"
EXPIRY_THRESHOLD=30

# -----------------------------------
# Validate Input
# -----------------------------------
validate_input() {

    if [[ -z "$DOMAIN" ]]; then
        echo "ERROR: Domain name not provided"
        echo "Usage: $0 <domain>"
        exit 1
    fi
}

# -----------------------------------
# Check SSL Expiry
# -----------------------------------
check_ssl_expiry() {

    expiry_date=$(echo | openssl s_client -connect "${DOMAIN}:443" \
    -servername "$DOMAIN" 2>/dev/null | \
    openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)

    if [[ -z "$expiry_date" ]]; then
        echo "ERROR: Unable to fetch SSL certificate"
        exit 1
    fi

    expiry_epoch=$(date -d "$expiry_date" +%s)

    current_epoch=$(date +%s)

    remaining_days=$(( (expiry_epoch - current_epoch) / 86400 ))

    echo "Domain          : $DOMAIN"
    echo "Expiry Date     : $expiry_date"
    echo "Remaining Days  : $remaining_days"

    if [[ "$remaining_days" -le "$EXPIRY_THRESHOLD" ]]; then

        echo "ALERT: SSL certificate expiring soon"

    else

        echo "SSL certificate is healthy"

    fi
}

# -----------------------------------
# Main Function
# -----------------------------------
main() {

    validate_input

    check_ssl_expiry
}

main
