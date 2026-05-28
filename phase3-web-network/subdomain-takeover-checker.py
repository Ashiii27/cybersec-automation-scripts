#!/usr/bin/env python3
# ==============================================================================
# Script Name: subdomain-takeover-checker.py
# Description: Detects dangling DNS pointing to unclaimed services.
# Phase: 3 (Web & Network)
# ==============================================================================

import dns.resolver
import sys

# Common service signatures indicating a potential subdomain takeover
SIGNATURES = {
    "GitHub Pages": "There isn't a GitHub Pages site here",
    "Heroku": "herokucdn.com/error-pages/no-such-app.html",
    "AWS S3": "NoSuchBucket",
    "Shopify": "Sorry, this shop is currently unavailable"
}

def check_subdomain(subdomain):
    print(f"[*] Checking subdomain: {subdomain}")
    try:
        # Resolve CNAME
        answers = dns.resolver.resolve(subdomain, 'CNAME')
        for rdata in answers:
            cname = str(rdata.target)
            print(f"  [+] CNAME: {cname}")
            # Here we would send an HTTP request to the subdomain and look for signatures
            # response = requests.get(f"http://{subdomain}", timeout=5)
            # if any(sig in response.text for sig in SIGNATURES.values()):
            #     print("[!] VULNERABLE TO SUBDOMAIN TAKEOVER!")
    except Exception as e:
        print(f"  [-] DNS lookup failed or CNAME not found: {e}")

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 subdomain-takeover-checker.py <subdomain>")
        sys.exit(1)
        
    subdomain = sys.argv[1]
    check_subdomain(subdomain)

if __name__ == "__main__":
    main()
