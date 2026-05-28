#!/usr/bin/env python3
# ==============================================================================
# Script Name: js-secret-scraper.py
# Description: Extracts API keys, tokens, and passwords from JavaScript files.
# Phase: 3 (Web & Network)
# ==============================================================================

import re
import sys
import requests

def extract_secrets(js_url):
    print(f"[*] Fetching JavaScript content from: {js_url}")
    try:
        # response = requests.get(js_url, timeout=10)
        # content = response.text
        content = "Sample JavaScript file with: const apiKey = 'AIzaSyA123456789...';"
        
        # Define common regex patterns for secrets
        patterns = {
            "Google API Key": r"AIza[0-9A-Za-z-_]{35}",
            "AWS API Key": r"AKIA[0-9A-Z]{16}",
            "Generic Secret/Token": r"(?i)(secret|token|password|auth|key)\s*[:=]\s*['\"][0-9a-zA-Z-_]{16,}['\"]"
        }
        
        found_secrets = []
        for name, pattern in patterns.items():
            matches = re.findall(pattern, content)
            if matches:
                for match in matches:
                    found_secrets.append((name, match))
                    
        return found_secrets
    except Exception as e:
        print(f"[-] Error: {e}")
        return []

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 js-secret-scraper.py <js_url>")
        sys.exit(1)
        
    js_url = sys.argv[1]
    secrets = extract_secrets(js_url)
    
    if secrets:
        print("[+] Found potential secrets:")
        for name, secret in secrets:
            print(f"  - [{name}]: {secret}")
    else:
        print("[-] No secrets found.")

if __name__ == "__main__":
    main()
