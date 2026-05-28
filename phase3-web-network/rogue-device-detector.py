#!/usr/bin/env python3
# ==============================================================================
# Script Name: rogue-device-detector.py
# Description: Monitors network for unknown MAC addresses and alerts.
# Phase: 3 (Web & Network)
# ==============================================================================

import os
import sys
import time

KNOWN_DEVICES_FILE = "known_devices.txt"

def load_known_devices():
    if not os.path.exists(KNOWN_DEVICES_FILE):
        return set()
    with open(KNOWN_DEVICES_FILE, "r") as f:
        return set(line.strip().lower() for line in f if line.strip())

def scan_network():
    print("[*] Scanning local network...")
    # Placeholder: run arp-scan or scapy to find active hosts/MACs
    # Example mock results:
    return [
        {"ip": "192.168.1.1", "mac": "aa:bb:cc:dd:ee:ff"},
        {"ip": "192.168.1.10", "mac": "11:22:33:44:55:66"}
    ]

def main():
    known_macs = load_known_devices()
    print(f"[*] Loaded {len(known_macs)} known device(s).")
    
    active_devices = scan_network()
    
    rogue_found = False
    for device in active_devices:
        mac = device["mac"].lower()
        if mac not in known_macs:
            print(f"[!] ROGUE DEVICE DETECTED: IP={device['ip']}, MAC={device['mac']}")
            rogue_found = True
            
    if not rogue_found:
        print("[+] All active devices are known and authorized.")

if __name__ == "__main__":
    main()
