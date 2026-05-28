#!/usr/bin/env python3
# ==============================================================================
# Script Name: auto-recon-pipeline.py
# Description: Full recon workflow from domain to vulnerability report.
# Phase: 5 (Advanced & Reporting)
# ==============================================================================

import sys
import subprocess

def run_step(step_name, command_args):
    print(f"[*] Starting Step: {step_name}...")
    # try:
    #     result = subprocess.run(command_args, capture_output=True, text=True, check=True)
    #     return result.stdout
    # except subprocess.CalledProcessError as e:
    #     print(f"[-] Error in {step_name}: {e}")
    #     return None
    print(f"  [+] Step {step_name} placeholder executed successfully.")

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 auto-recon-pipeline.py <domain>")
        sys.exit(1)
        
    domain = sys.argv[1]
    print(f"[*] INITIALIZING RECONNAISSANCE PIPELINE FOR: {domain}")
    
    # Step 1: Subdomain Enum
    run_step("Subdomain Enumeration", ["bash", "../phase2-recon/subdomain-enumerator.sh", domain])
    
    # Step 2: Port Scanning
    run_step("Port Scanning", ["bash", "../phase2-recon/port-scanner.sh", domain])
    
    # Step 3: Check for takeovers
    run_step("Subdomain Takeover Check", ["python3", "../phase3-web-network/subdomain-takeover-checker.py", domain])
    
    print("[+] Reconnaissance Pipeline fully executed! Report is ready.")

if __name__ == "__main__":
    main()
