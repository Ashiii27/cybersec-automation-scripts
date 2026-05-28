#!/bin/bash
# ==============================================================================
# Script Name: tool-installer.sh
# Description: Installs a full pentesting toolkit on a fresh Kali machine.
# Phase: 1 (Foundations & Bash Basics)
# ==============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}[*] Initializing Kali Pentesting Toolkit Installer...${NC}"

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[!] Please run as root or using sudo.${NC}"
    exit 1
fi

echo -e "${GREEN}[+] Running apt update and upgrade...${NC}"
# apt-get update && apt-get upgrade -y

echo -e "${YELLOW}[!] Tool installation placeholder. Add your tools here.${NC}"
# Examples: apt-get install -y nmap subfinder amass gobuster nikto nuclei sqlmap curl ffuf

echo -e "${GREEN}[+] Installation complete!${NC}"
