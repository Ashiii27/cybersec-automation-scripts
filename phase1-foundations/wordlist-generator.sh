#!/bin/bash
# ==============================================================================
# Script Name: wordlist-generator.sh
# Description: Generates custom wordlists based on target information.
# Phase: 1 (Foundations & Bash Basics)
# ==============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_usage() {
    echo "Usage: $0 -t <target_name> -y <year> -o <output_file>"
    echo "Options:"
    echo "  -t  Target organization/name (e.g., Tesla)"
    echo "  -y  Target year/important year (e.g., 2026)"
    echo "  -o  Output file name"
    exit 1
}

# Parse options
TARGET=""
YEAR=""
OUTPUT=""

while getopts "t:y:o:h" opt; do
    case ${opt} in
        t ) TARGET=$OPTARG ;;
        y ) YEAR=$OPTARG ;;
        o ) OUTPUT=$OPTARG ;;
        h | * ) show_usage ;;
    esac
done

if [ -z "$TARGET" ] || [ -z "$YEAR" ] || [ -z "$OUTPUT" ]; then
    show_usage
fi

echo -e "${BLUE}[*] Generating custom wordlist for target: ${TARGET}...${NC}"

# Simple permutations generation placeholder
{
    echo "${TARGET}"
    echo "${TARGET,,}" # Lowercase
    echo "${TARGET^^}" # Uppercase
    echo "${TARGET}${YEAR}"
    echo "${TARGET}@${YEAR}"
    echo "${TARGET}123"
} > "$OUTPUT"

echo -e "${GREEN}[+] Custom wordlist successfully saved to ${OUTPUT}!${NC}"
