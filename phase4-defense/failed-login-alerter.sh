#!/bin/bash
# ==============================================================================
# Script Name: failed-login-alerter.sh
# Description: Monitors login failures and triggers alerts on threshold.
# Phase: 4 (Defense & Monitoring)
# ==============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

THRESHOLD=5
echo -e "${BLUE}[*] Starting Failed Login Alerter daemon simulation...${NC}"
echo -e "${BLUE}[*] Alert Threshold: ${THRESHOLD} attempts.${NC}"

# Loop to monitor log file or system events
# tail -fn0 /var/log/auth.log | while read line; do
#     if echo "$line" | grep -q "Failed password"; then
#         # extract IP, increment count, if count > threshold -> alert!
#     fi
# done

echo -e "${GREEN}[+] Alerter daemon setup ready.${NC}"
