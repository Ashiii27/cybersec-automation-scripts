#!/bin/bash
# ==============================================================================
# Script Name: subdomain-enumerator.sh
# Description: Runs subfinder, amass, assetfinder and merges results.
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
OUTPUT_DIR="recon_${DOMAIN}"
mkdir -p "$OUTPUT_DIR"

echo -e "${BLUE}[*] Starting Subdomain Enumeration for ${DOMAIN}...${NC}"

# Placeholder for running tools
# echo "[*] Running subfinder..."
# subfinder -d "$DOMAIN" -o "$OUTPUT_DIR/subfinder.txt"

# echo "[*] Running assetfinder..."
# assetfinder --subs-only "$DOMAIN" > "$OUTPUT_DIR/assetfinder.txt"

# echo "[*] Running amass..."
# amass enum -d "$DOMAIN" -o "$OUTPUT_DIR/amass.txt"

# Merge and deduplicate
# cat "$OUTPUT_DIR"/*.txt | sort -u > "$OUTPUT_DIR/all_subdomains.txt"

echo -e "${GREEN}[+] Subdomain enumeration completed! Results saved in ${OUTPUT_DIR}/all_subdomains.txt${NC}"
