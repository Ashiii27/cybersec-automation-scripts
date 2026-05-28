#!/usr/bin/env python3
# ==============================================================================
# Script Name: file-integrity-monitor.py
# Description: Detects unauthorized changes to critical system files.
# Phase: 4 (Defense & Monitoring)
# ==============================================================================

import hashlib
import os
import sys
import json

DB_FILE = "file_integrity_db.json"

def calculate_sha256(filepath):
    sha256_hash = hashlib.sha256()
    try:
        with open(filepath, "rb") as f:
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)
        return sha256_hash.hexdigest()
    except (FileNotFoundError, PermissionError):
        return None

def build_baseline(directories):
    print("[*] Building file integrity baseline...")
    baseline = {}
    for directory in directories:
        if not os.path.exists(directory):
            continue
        for root, _, files in os.walk(directory):
            for file in files:
                filepath = os.path.join(root, file)
                file_hash = calculate_sha256(filepath)
                if file_hash:
                    baseline[filepath] = file_hash
                    
    with open(DB_FILE, "w") as f:
        json.dump(baseline, f, indent=4)
    print(f"[+] Baseline stored successfully in {DB_FILE}!")

def check_integrity():
    if not os.path.exists(DB_FILE):
        print("[-] Baseline database not found! Please build baseline first.")
        sys.exit(1)
        
    with open(DB_FILE, "r") as f:
        baseline = json.load(f)
        
    print("[*] Verifying integrity against baseline...")
    for filepath, expected_hash in baseline.items():
        current_hash = calculate_sha256(filepath)
        if current_hash is None:
            print(f"[!] MISSING FILE: {filepath}")
        elif current_hash != expected_hash:
            print(f"[!] MODIFIED FILE DETECTED: {filepath}")
            
    print("[+] Check complete.")

def main():
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python3 file-integrity-monitor.py init <dir1> <dir2> ...")
        print("  python3 file-integrity-monitor.py check")
        sys.exit(1)
        
    mode = sys.argv[1].lower()
    if mode == "init":
        dirs = sys.argv[2:]
        if not dirs:
            print("[-] Please specify at least one directory to initialize.")
            sys.exit(1)
        build_baseline(dirs)
    elif mode == "check":
        check_integrity()
    else:
        print("[-] Invalid mode.")

if __name__ == "__main__":
    main()
