#!/usr/bin/env bash
# =============================================================================
# Professional Wordlist Generator — Refactored
# Generates targeted wordlists for authorized security testing.
# Improvements: robust args parsing, dependency checks, safe writes, resource limits,
# atomic output, proper traps, stdin support, dry-run, and better performance.
# =============================================================================

set -Eeuo pipefail

# Globals
VERSION="3.0"
LOGFILE="/var/log/wordlist-generator.log"
TMP_DIR=""
START_TIME=$(date +%s)

# Defaults
MAX_WORDS=500000
MAX_OUTPUT_MB=100
COMPRESS=false
VERBOSE=false
DRY_RUN=false
FORCE=false
READ_STDIN=false

TARGET=""
OUTPUT=""
BASE_WORDS=()
YEARS=()
LEET=false
MONTHS=false
SEASONS=false
COMMON_PATTERNS=true
CASE="lower,upper,capitalize"
SEPARATORS=","   # comma separated
SPECIAL_CHARS="!@#"
DIGITS="0-9"

# Counters and files
WRITE_COUNT=0
RAW_FILE=""

# Utilities check
required_cmds=(mktemp sort du awk gzip zcat fold getopt)

info(){ [[ "$VERBOSE" == true ]] && echo -e "[+] $*"; }
warn(){ echo -e "[!] $*" >&2; }
err(){ echo -e "[-] $*" >&2; cleanup; exit 1; }

cleanup(){
    if [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]]; then
        rm -rf "$TMP_DIR"
    fi
}

trap 'err "Error at line $LINENO"' ERR
trap cleanup EXIT INT TERM

show_help(){
cat <<EOF
Professional Wordlist Generator v${VERSION}

Usage: $0 [OPTIONS] -o <output>

Required:
  -o, --output FILE       Output file (required)

Input sources:
  -t, --target WORD       Target/company name (added to base words)
  -b, --base-file FILE    File with base words (one per line)
  -w, --word WORD         Add single base word (repeatable)
  --stdin                 Read base words from stdin

Mutation options:
  -y, --years LIST        Comma-separated years (e.g. 2020,2021)
  -l, --leet              Enable leet substitutions (bounded)
  -m, --months            Include month names
  --seasons               Include seasons
  -c, --case TYPES        Case mutations (comma-separated)
  -s, --separators CHARS  Separators to try (comma-separated)
  --digits RANGE          Digit range or list (e.g. 0-99 or 00-99)
  --special CHARS         Special characters to append

Limits & misc:
  --max-words N           Max number of entries (default: ${MAX_WORDS})
  --max-size MB           Max output size in MB (default: ${MAX_OUTPUT_MB})
  --compress              Gzip the output
  --dry-run               Show what would be generated (no file writes)
  --force                 Overwrite output if exists
  -v, --verbose           Verbose mode
  -h, --help              Show this help

Examples:
  $0 -t Acme -y 2023,2024 -o acme.txt
  cat words.txt | $0 --stdin -o combined.txt
EOF
exit 0
}

validate_int(){
    local val="$1" name="$2"
    if ! [[ "$val" =~ ^[0-9]+$ ]]; then
        err "Invalid integer for $name: $val"
    fi
}

check_cmds(){
    for cmd in "${required_cmds[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            err "Required command not found: $cmd"
        fi
    done
}

increment_write(){
    (( WRITE_COUNT++ ))
    if (( WRITE_COUNT % 1000 == 0 )); then
        # periodic size check
        if [[ -f "$RAW_FILE" ]]; then
            local size_mb
            size_mb=$(du -m "$RAW_FILE" | awk '{print $1}')
            if (( size_mb > MAX_OUTPUT_MB )); then
                err "Temporary file exceeded ${MAX_OUTPUT_MB}MB"
            fi
        fi
    fi
    if (( WRITE_COUNT > MAX_WORDS )); then
        err "Reached maximum word limit (${MAX_WORDS})"
    fi
}

safe_write(){
    local line="$1"
    if [[ -z "$line" ]]; then
        return
    fi
    echo "$line" >> "$RAW_FILE"
    increment_write
}

expand_digits(){
    local range="$1"
    if [[ "$range" =~ ^([0-9]+)-([0-9]+)$ ]]; then
        local start=${BASH_REMATCH[1]} end=${BASH_REMATCH[2]}
        local width=${#start}
        for ((i=10#$start;i<=10#$end;i++)); do
            printf "%0${width}d\n" "$i"
        done
    else
        # comma or single values
        IFS=',' read -ra parts <<< "$range"
        for p in "${parts[@]}"; do echo "$p"; done
    fi
}

case_mutate(){
    local word="$1"
    IFS=',' read -ra case_list <<< "$CASE"
    for c in "${case_list[@]}"; do
        case "$c" in
            lower) echo "${word,,}" ;;
            upper) echo "${word^^}" ;;
            capitalize) echo "${word^}" ;;
            toggle)
                local toggled=""
                for ((i=0;i<${#word};i++)); do
                    ch="${word:i:1}"
                    if (( i % 2 == 0 )); then toggled+="${ch,}"; else toggled+="${ch^}"; fi
                done
                echo "$toggled"
                ;;
        esac
    done
}

# produce limited leet variants (single and double substitutions)
leet_variants(){
    local w="$1"
    declare -A map=( [a]=@ [o]=0 [e]=3 [i]=1 [s]=\$ )
    local variants=("$w")
    # single substitutions
    for k in "${!map[@]}"; do
        if [[ "$w" == *"$k"* ]]; then
            variants+=("${w//$k/${map[$k]}}")
        fi
    done
    # two-char combos (bounded)
    for k1 in "${!map[@]}"; do
        for k2 in "${!map[@]}"; do
            if [[ "$k1" != "$k2" ]]; then
                if [[ "$w" == *"$k1"* && "$w" == *"$k2"* ]]; then
                    local tmp="$w"
                    tmp="${tmp//$k1/${map[$k1]}}"
                    tmp="${tmp//$k2/${map[$k2]}}"
                    variants+=("$tmp")
                fi
            fi
        done
    done
    printf "%s\n" "${variants[@]}" | sort -u
}

combine_words(){
    local w1="$1" w2="$2"
    IFS=',' read -ra seps <<< "$SEPARATORS"
    for sep in "${seps[@]}"; do
        echo "${w1}${sep}${w2}"
    done
    echo "${w1}${w2}"
}

generate(){
    TMP_DIR=$(mktemp -d)
    RAW_FILE="$TMP_DIR/raw.txt"
    touch "$RAW_FILE"

    info "Generating mutations to $RAW_FILE"

    # read base words from stdin if requested
    if $READ_STDIN; then
        while IFS= read -r line; do
            [[ -n "$line" ]] && BASE_WORDS+=("$line")
        done
    fi

    for word in "${BASE_WORDS[@]}"; do
        while IFS= read -r variant; do
            safe_write "$variant"

            if $LEET; then
                while IFS= read -r lvar; do
                    safe_write "$lvar"
                done < <(leet_variants "$variant")
            fi

            for year in "${YEARS[@]}"; do
                safe_write "${variant}${year}"
                safe_write "${year}${variant}"
            done

            while IFS= read -r digit; do
                safe_write "${variant}${digit}"
            done < <(expand_digits "$DIGITS")

            # special chars
            while IFS= read -r -n1 ch; do
                [[ -z "$ch" ]] && break
                safe_write "${variant}${ch}"
            done <<< "${SPECIAL_CHARS}"

        done < <(case_mutate "$word")
    done

    if $COMMON_PATTERNS; then
        COMMON=(admin welcome password changeme security letmein company login)
        for base in "${BASE_WORDS[@]}"; do
            for common in "${COMMON[@]}"; do
                combine_words "$base" "$common" >> "$RAW_FILE"
            done
        done
    fi

    if $MONTHS; then
        MONTHS_LIST=(January February March April May June July August September October November December)
        for base in "${BASE_WORDS[@]}"; do
            for m in "${MONTHS_LIST[@]}"; do
                combine_words "$base" "$m" >> "$RAW_FILE"
            done
        done
    fi

    if $SEASONS; then
        SEASONS_LIST=(Spring Summer Autumn Winter)
        for base in "${BASE_WORDS[@]}"; do
            for s in "${SEASONS_LIST[@]}"; do
                combine_words "$base" "$s" >> "$RAW_FILE"
            done
        done
    fi

    info "Sorting, deduplicating and writing final output"

    local out_tmp="${OUTPUT}.tmp"
    if $DRY_RUN; then
        info "Dry-run enabled — skipping file write. Showing sample lines:"; head -n 50 "$RAW_FILE"; return
    fi

    # atomic write
    sort -u "$RAW_FILE" > "$out_tmp"

    # final size checks
    local size_mb
    size_mb=$(du -m "$out_tmp" | awk '{print $1}')
    if (( size_mb > MAX_OUTPUT_MB )); then
        rm -f "$out_tmp"
        err "Final output exceeded ${MAX_OUTPUT_MB}MB"
    fi

    if [[ -f "$OUTPUT" && "$FORCE" != true ]]; then
        err "Output exists: $OUTPUT (use --force to overwrite)"
    fi

    mv "$out_tmp" "$OUTPUT"

    if $COMPRESS; then
        gzip -f "$OUTPUT"
        OUTPUT+=".gz"
    fi
}

show_stats(){
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    local lines size
    lines=$(wc -l < <(zcat -f "$OUTPUT" 2>/dev/null || cat "$OUTPUT"))
    size=$(du -h "$OUTPUT" | awk '{print $1}')

    echo
    echo "========================================"
    echo " Wordlist Generation Complete"
    echo "========================================"
    echo
    echo "Output File : $OUTPUT"
    echo "Entries     : $lines"
    echo "Size        : $size"
    echo "Duration    : ${duration}s"
    echo
}

# ----------------------
# Argument parsing (getopt)
# ----------------------

LONGOPTS="target:,base-file:,word:,output:,years:,leet,months,seasons,no-common,case:,separators:,digits:,special:,max-words:,max-size:,compress,dry-run,stdin,force,verbose,help"
SHORTOPTS="t:b:w:o:y:lmchv"

PARSED=$(getopt --options "$SHORTOPTS" --longoptions "$LONGOPTS" --name "$0" -- "$@") || show_help
eval set -- "$PARSED"

while true; do
    case "$1" in
        -t|--target) TARGET="$2"; shift 2 ;;
        -b|--base-file) [[ -f "$2" ]] || err "Base file not found: $2"; mapfile -t tmpf < "$2"; BASE_WORDS+=("${tmpf[@]}"); shift 2 ;;
        -w|--word) BASE_WORDS+=("$2"); shift 2 ;;
        -o|--output) OUTPUT="$2"; shift 2 ;;
        -y|--years) IFS=',' read -ra YEARS <<< "$2"; shift 2 ;;
        -l|--leet) LEET=true; shift ;;
        -m|--months) MONTHS=true; shift ;;
        --seasons) SEASONS=true; shift ;;
        --no-common) COMMON_PATTERNS=false; shift ;;
        -c|--case) CASE="$2"; shift 2 ;;
        -s|--separators) SEPARATORS="$2"; shift 2 ;;
        --digits) DIGITS="$2"; shift 2 ;;
        --special) SPECIAL_CHARS="$2"; shift 2 ;;
        --max-words) validate_int "$2" "max-words"; MAX_WORDS="$2"; shift 2 ;;
        --max-size) validate_int "$2" "max-size"; MAX_OUTPUT_MB="$2"; shift 2 ;;
        --compress) COMPRESS=true; shift ;;
        --dry-run) DRY_RUN=true; shift ;;
        --stdin) READ_STDIN=true; shift ;;
        --force) FORCE=true; shift ;;
        -v|--verbose) VERBOSE=true; shift ;;
        -h|--help|--) show_help ;;
        *) break ;;
    esac
done

# Validate required args
[[ -n "$OUTPUT" ]] || err "Output file required (-o)"

if [[ -z "$TARGET" && ${#BASE_WORDS[@]} -eq 0 && "$READ_STDIN" != true ]]; then
    err "Provide --target, --base-file, --word, or --stdin"
fi

[[ -n "$TARGET" ]] && BASE_WORDS+=("$TARGET")

check_cmds

info "Starting wordlist generation v${VERSION}"
info "Temp dir and raw file will be created"

generate

if [[ "$DRY_RUN" != true ]]; then
    show_stats
fi

cleanup

exit 0
