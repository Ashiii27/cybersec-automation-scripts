#!/bin/bash
# ==============================================================================
# Script Name: passive-recon-aggregator.sh
# Description: Pulls WHOIS, DNS records, and certificate data into one report.
# Phase: 2 (Reconnaissance)
# ==============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ $# -ne 1 ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

DOMAIN=$1
REPORT_FILE="${DOMAIN}_passive_recon.txt"

echo -e "${BLUE}[*] Gathering Passive Reconnaissance for ${DOMAIN}...${NC}"

{
    echo "========================================="
    echo "PASSIVE RECON REPORT FOR: ${DOMAIN}"
    echo "Date: $(date)"
    echo "========================================="
    echo ""
    echo "[1] WHOIS DATA"
    echo "-----------------------------------------"
    # whois "$DOMAIN"
    echo "Placeholder WHOIS info..."
    echo ""
    echo "[2] DNS RECORDS (ANY)"
    echo "-----------------------------------------"
    # dig "$DOMAIN" ANY +noall +answer
    echo "Placeholder DNS info..."
    echo ""
    echo "[3] CERTIFICATE TRANSPARENCY (crt.sh)"
    echo "-----------------------------------------"
    # curl -s "https://crt.sh/?q=%25.${DOMAIN}&output=json" | jq -r '.[].name_value' | sort -u
    echo "Placeholder Certificate info..."
} > "$REPORT_FILE"

echo -e "${GREEN}[+] Passive recon completed! Report saved to ${REPORT_FILE}${NC}"
